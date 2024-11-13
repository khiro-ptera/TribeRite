extends MarginContainer

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var cardName = "Flowerbeds"
@onready var cardIndex = cardDatabase[cardName]
@onready var cardInfo = cardDatabase.DATA[cardIndex].duplicate()
@onready var cardImage = str("res://Assets/Cards/" + cardInfo[0] + "/" + cardInfo[1] + ".png")
@onready var borderImage = str("res://Assets/Cards/templates/" + cardInfo[0] + ".png")
@onready var ogScalex = scale.x
@onready var ogScale = scale
@onready var activePos = Vector2($".".get_viewport().size.x * 0.60, $".".get_viewport().size.y * 0.25)

enum{
	InHand, 
	InActive, 
	InStack, 
	InDZone,
	Drawn,
	FocusInHand,
	BeneathDZone,
	Played,
}
var state = InHand
var startpos = 0
var targetpos = 0
var t = 0
var drawtime = 0.6
var handPos = 0
var stackPos = 0
var atkAuraBoost = 0
var hpAuraBoost = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Border.texture = load(borderImage)
	# $Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(cardImage)
	# var defaultScale = scale.x
	updateCard()
	
func _physics_process(delta: float) -> void:
	match state:
		InHand:
			while !Global.hand[handPos-1] && handPos > 0:
				var temp = Global.hand
				temp[handPos] = false
				handPos -= 1
				temp[handPos] = true
				Global.hand = temp
				position =  Vector2($".".get_viewport().size) * Vector2(0.2, 1.0) - size/2 + Vector2((handPos) * size.x * (4.0/Global.maxHandSize), -20)
		InActive:
			var totalHP = cardInfo[4] + hpAuraBoost
			var totalATK = cardInfo[3] + atkAuraBoost
			monsterAura()
			if cardInfo != Global.stack[0] || atkAuraBoost != 0 || hpAuraBoost != 0: # update card
				cardInfo = Global.stack[0]
				updateCard()
		InStack:
			var totalHP = cardInfo[4] + hpAuraBoost
			var totalATK = cardInfo[3] + atkAuraBoost
			monsterAura()
			if cardInfo != Global.stack[stackPos] || atkAuraBoost != 0 || hpAuraBoost != 0: # update card
				cardInfo = Global.stack[stackPos]
				updateCard()
		InDZone:
			if Global.dZone != cardInfo[1]:
				visible = false
				state = BeneathDZone
		Drawn: # drawing from deck into hand
			if t <= 1:
				position = startpos.lerp(targetpos, t)
				scale.x = ogScalex * abs(2*t - 1)
				if t > 0.5:
					$"CardBack".hide()
				t += delta/drawtime
				visible = true
			else:
				position = targetpos
				scale.x = ogScalex
				if targetpos == Vector2($".".get_viewport().size) - size/1.25 - size*0.01:
					Global.dZone = cardInfo[1]
					state = InDZone
					print("discarded!")
				else:
					state = InHand
				t = 0
		FocusInHand:
			if t <= 1:
				scale *= 1.02
				position = startpos.lerp(targetpos, t)
				t += delta/0.25
			else:
				position = targetpos
				# t = 0
		BeneathDZone:
			pass
		Played: # hand to board
			if t <= 1:
				scale *= 0.99
				position = startpos.lerp(targetpos, t)
				t += delta/0.3
			else:
				position = targetpos
				monsterBirthrite()
				if targetpos == activePos:
					state = InActive
				else:
					state = InStack
				# t = 0

func _on_hover_mouse_entered() -> void:
	match state:
		InHand:
			ogScale = scale
			startpos = position
			targetpos = position - Vector2(0, 180)
			state = FocusInHand

func _on_hover_mouse_exited() -> void:
	match state:
		FocusInHand:
			t = 0
			scale = ogScale
			position = startpos
			state = InHand

func _on_hover_button_up() -> void:
	match state:
		FocusInHand:
			t = 0
			scale = ogScale
			if Global.playerTurn:
				if cardInfo[0] == "Monsters" && Global.phase == 1:
					if Global.stackSize == 0: # play active
						Global.stack[0] = cardInfo
						removeFromHand()
						stackPos = Global.stackSize
						startpos = position
						targetpos = activePos # position of active
						Global.stackSize += 1
						print(Global.stack)
						state = Played
					elif Global.stackSize <= 3:
						if cardInfo[5] == 0:
							Global.stack[Global.stackSize] = cardInfo
							removeFromHand()
							stackPos = Global.stackSize
							startpos = position
							targetpos = activePos + Vector2(-Global.stackSize * Global.cardSize.x, Global.cardSize.y * 0.5)
							Global.stackSize += 1
							print(Global.stack)
							state = Played
					else:
						pass
				elif cardInfo[0] == "Spells" && Global.phase == 1:
					# spell effect
					spellEffects()
					Global.dZone = cardInfo[1]
					removeFromHand()
					state = InDZone
					position = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
				elif cardInfo[0] == "Arenas" && Global.phase == 1:
					pass
				elif cardInfo[0] == "Counters" && Global.phase == 2:
					pass
				
func removeFromHand():
	Global.hand[handPos] = false
	Global.handSize -= 1
	
func updateCard():
	var stat1 = ""
	var stat2 = ""
	var element = ""
	var effect = ""
	var sacrifice = ""
	var fullname = cardInfo[1]
	
	if cardInfo[0] == "Monsters":
		stat1 = str(cardInfo[3] + atkAuraBoost)
		stat2 = str(cardInfo[4] + hpAuraBoost)
		element = cardInfo[2]
		sacrifice = str(cardInfo[5])
		effect = cardInfo[7]
		$Bars/Stats/Stat1/CenterContainer/Label.label_settings.font_color = Color(1, 0, 0, 1)
	elif cardInfo[0] == "Counters":
		stat1 = str(cardInfo[2])
		effect = cardInfo[3]
		$Bars/Stats/Stat1/CenterContainer/Label.label_settings.font_color = Color(1, 1, 0, 1)
	elif cardInfo[0] == "Spells":
		effect = cardInfo[2]
	else:
		effect = cardInfo[2]
		
	$Bars/BottomBar/Element/CenterContainer/Label.text = element
	$Bars/BottomBar/Sacrifice/CenterContainer/Label.text = sacrifice
	$Bars/EffectBar/Effect/CenterContainer/Label.text = effect
	$Bars/NameBar/Name/CenterContainer/Label.text = fullname
	$Bars/Stats/Stat1/CenterContainer/Label.text = stat1
	$Bars/Stats/Stat2/CenterContainer/Label.text = stat2
	
func monsterBirthrite():
	pass
	
func monsterAura():
	if cardInfo[1] == "Polarius":
		atkAuraBoost = (Global.stackSize - 1) * 10
	
func monsterDeathrite():
	pass

func monsterOnKill():
	pass
	
func spellEffects():
	if cardInfo[1] == "Enrage": 
		var targetIndex = cardDatabase[Global.stack[0][1]]
		var tempInfo = cardDatabase.DATA[targetIndex]
		var tempCopy = tempInfo.duplicate()
		tempCopy[3] += 25
		Global.stack[0] = tempCopy
	
func counterEffects():
	pass
	
func arenaAura():
	pass
