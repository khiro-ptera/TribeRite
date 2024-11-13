extends MarginContainer

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var cardName = "Flowerbeds"
@onready var cardIndex = cardDatabase[cardName]
@onready var cardInfo = cardDatabase.DATA[cardIndex].duplicate()
@onready var cardImage = str("res://Assets/Cards/" + cardInfo[0] + "/" + cardName + ".png")
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
	SacState,
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
var fieldScale = ogScale

signal allyBuff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(cardImage)
	$CardBack.visible = true
	$Bars/BottomBar/SacIcon.visible = false
	$Bars/Stats/ATKicon.visible = false
	$Bars/Stats/HPicon.visible = false
	$Border.texture = load(borderImage)
	# $Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(cardImage)
	# var defaultScale = scale.x
	updateCard()
	
func _physics_process(delta: float) -> void:
	# print(Global.stack)
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
			position = activePos 
			var totalHP = cardInfo[4] + hpAuraBoost
			var totalATK = cardInfo[3] + atkAuraBoost
			monsterAura()
			# cardInfo = Global.stack[0]
			updateCard()
			if Global.sacrifice[0] == true:
				destroy()
		InStack:
			var totalHP = cardInfo[4] + hpAuraBoost
			var totalATK = cardInfo[3] + atkAuraBoost
			monsterAura()
			# cardInfo = Global.stack[stackPos]
			updateCard()
			position = activePos + Vector2(-stackPos * Global.cardSize.x, Global.cardSize.y * 0.5)
			if Global.sacrifice[stackPos] == true:
				destroy()
			elif Global.stack[stackPos-1] == []:
				print("shshsh")
				shiftUpStack()
		InDZone:
			scale = Global.cardSize / size
			position = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
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
					Global.dZone = cardInfo[1] # ALWAYS DO THIS BEFORE DISCARD
					state = InDZone
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
				fieldScale = scale
				position = targetpos
				monsterBirthrite()
				if targetpos == activePos:
					state = InActive
				else:
					state = InStack
				# t = 0
		SacState:
			if !Global.sacrificeState:
				await get_tree().process_frame
				playMonsterStack()

func _on_hover_mouse_entered() -> void:
	match state:
		InHand:
			ogScale = scale
			startpos = position
			targetpos = position - Vector2(0, 180)
			state = FocusInHand
		InActive, InStack:
			scale = ogScale*1.4

func _on_hover_mouse_exited() -> void:
	match state:
		FocusInHand:
			t = 0
			scale = ogScale
			position = startpos
			state = InHand
		InActive, InStack:
			scale = fieldScale

func _on_hover_button_up() -> void:
	match state:
		FocusInHand:
			t = 0
			scale = ogScale
			if Global.playerTurn && !Global.sacrificeState:
				if cardInfo[0] == "Monsters" && Global.phase == 1:
					if Global.stackSize == 0: # play active
						Global.stack[0] = cardInfo
						removeFromHand()
						stackPos = Global.stackSize
						startpos = position
						targetpos = activePos # position of active
						Global.stackSize += 1
						state = Played
					elif Global.stackSize <= 4:
						print("hihi")
						if cardInfo[5] == 0 && Global.stackSize <= 3:
							playMonsterStack()
						elif cardInfo[5] == 1:
							if Global.stackSize == 1:
								Global.sacReq = 1
								Global.sacrifice[0] = true
								playMonsterStack()
							else:
								state = SacState
								Global.sacrificeState = true
						elif cardInfo[5] == 2 && Global.stackSize >= 2:
							pass
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
		InActive, InStack:
			if Global.sacrificeState:
				Global.sacrifice[stackPos] = true
				Global.sacReq -= 1
				if Global.sacReq <= 0:
					Global.sacrificeState = false
				
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
		$Bars/BottomBar/SacIcon.visible = true
		$Bars/Stats/ATKicon.visible = true
		$Bars/Stats/HPicon.visible = true
	elif cardInfo[0] == "Counters":
		stat1 = str(cardInfo[2])
		effect = cardInfo[3]
		$Bars/Stats/Stat1/CenterContainer/Label.label_settings.font_color = Color(1, 1, 0, 1)
	elif cardInfo[0] == "Spells":
		effect = cardInfo[2]
	else:
		effect = cardInfo[2]
	
	if fullname.length() > 16:
		$Bars/NameBar/Name/CenterContainer/Label.label_settings.font_size = 16
	$Bars/BottomBar/Element/CenterContainer/Label.text = element
	$Bars/BottomBar/Sacrifice/CenterContainer/Label.text = sacrifice
	$Bars/EffectBar/Effect/CenterContainer/Label.text = effect
	$Bars/NameBar/Name/CenterContainer/Label.text = fullname
	$Bars/Stats/Stat1/CenterContainer/Label.text = stat1
	$Bars/Stats/Stat2/CenterContainer/Label.text = stat2
	
func playMonsterStack():
	Global.stack[Global.stackSize] = cardInfo
	removeFromHand()
	stackPos = Global.stackSize
	startpos = position
	targetpos = activePos + Vector2(-Global.stackSize * Global.cardSize.x, Global.cardSize.y * 0.5)
	Global.stackSize += 1
	state = Played
	
func monsterBirthrite():
	if cardInfo[1] == "Goopa":
		Global.buffInfo = [-1, 4, 20]
		allyBuff.emit()
	
func monsterAura():
	if cardInfo[1] == "Polarius":
		atkAuraBoost = (Global.stackSize - 1) * 10
	
func monsterDeathrite():
	if cardInfo[1] == "Goopa":
		Global.buffInfo = [-1, 4, 20]
		allyBuff.emit()
	elif cardInfo[1] == "Opturtle":
		Global.draws += 1

func monsterOnKill():
	pass
	
func spellEffects():
	if cardInfo[1] == "Enrage": 
		if Global.stack[0].size() != 0:
			Global.stack[0][3] += 25
	elif cardInfo[1] == "Noxatu Ritual":
		if Global.stack[0].size() != 0:
			Global.sacrifice[Global.stackSize-1] = true
			Global.draws += 2
	elif cardInfo[1] == "Bleakfountain Pact":
		Global.buffInfo = [0, 3, 30 * Global.draws]
		allyBuff.emit()
		Global.buffInfo = [0, 4, 30 * Global.draws]
		allyBuff.emit()
		Global.draws = 0
	
func counterEffects():
	pass
	
func arenaAura():
	pass

func dZoneAura():
	pass
	
func destroy(): # destroy monster
	Global.sacrifice[stackPos] = false
	Global.stack[stackPos] = []
	Global.stackSize -= 1
	monsterDeathrite()
	Global.dZone = cardInfo[1] # ALWAYS DO THIS BEFORE DISCARD
	state = InDZone
	
func shiftUpStack():
	if stackPos == 0 || Global.stack[stackPos-1] != []:
		pass
	Global.stack[stackPos] = []
	stackPos -= 1
	Global.stack[stackPos] = cardInfo
	if stackPos == 0:
		state = InActive
	print(Global.stack)
	print(Global.stackSize)
