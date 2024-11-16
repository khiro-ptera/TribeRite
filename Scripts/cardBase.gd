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
@onready var arenaPos = Vector2($".".get_viewport().size.x * 0.20, $".".get_viewport().size.y * 0.25)
@onready var elements = ["All", "Fire", "Water", "Earth", "Electric", "Steel", "Sky", "Magic"]

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
	Arena,
	SentDZone,
}
var state = InHand
var startpos = 0
var targetpos = 0
var t = 0
var drawtime = 0.6
var handPos = 0
var stackPos = 0
var auraBuff = [0, 0]
var fieldScale = ogScale

signal allyBuff

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			var totalHP = cardInfo[4] + auraBuff[1]
			var totalATK = cardInfo[3] + auraBuff[0]
			monsterAura()
			# cardInfo = Global.stack[0]
			updateCard()
			if Global.sacrifice[0] == true:
				destroy()
		InStack:
			var totalHP = cardInfo[4] + auraBuff[1]
			var totalATK = cardInfo[3] + auraBuff[0]
			monsterAura()
			# cardInfo = Global.stack[stackPos]
			updateCard()
			position = activePos + Vector2(-stackPos * Global.cardSize.x, Global.cardSize.y * 0.5)
			if Global.sacrifice[stackPos] == true:
				destroy()
			elif (Global.stack[stackPos-1] == []) && !Global.sacrificeState: # INVESTIGATE THIS!!!
				# await get_tree().process_frame
				shiftUpStack()
		InDZone:
			scale = Global.cardSize / size
			position = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
			if Global.dZone != cardInfo[1]:
				dZoneAura("removed")
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
					#Global.dZone = cardInfo[1] # ALWAYS DO THIS BEFORE DISCARD
					#state = InDZone
					moveD()
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
				Global.moving = true
				scale *= 0.99
				position = startpos.lerp(targetpos, t)
				t += delta/0.3
			else:
				Global.moving = false
				fieldScale = scale
				position = targetpos
				if cardInfo[0] == "Monsters":
					monsterBirthrite()
					if targetpos == activePos:
						state = InActive
					else:
						state = InStack
				elif cardInfo[0] == "Arenas":
					# print("Arena played")
					# destroyArena.emit()
					# await get_tree().process_frame
					arena("played")
					# while Global.arena:
						# await get_tree().process_frame
					state = Arena
					Global.arena = true
					# t = 0
		SacState:
			if !Global.sacrificeState:
				await get_tree().process_frame
				Global.stack[3] = cardInfo
				removeFromHand()
				stackPos = 3
				startpos = position
				targetpos = activePos + Vector2(-Global.stackSize * Global.cardSize.x, Global.cardSize.y * 0.5)
				Global.stackSize += 1
				state = Played
		Arena:
			if Global.arena == false:
				arena("destroyed")
				monsterDeathrite()
				moveD()
		SentDZone:
			if t <= 1:
				Global.dZone = ""
				position = startpos.lerp(targetpos, t)
				t += delta/0.3
			else:
				position = targetpos
				Global.dZone = cardInfo[1]
				dZoneAura("sent")
				state = InDZone

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
	if Global.moving == true:
		return
	match state:
		FocusInHand:
			t = 0
			scale = ogScale
			if Global.playerTurn && !Global.sacrificeState:
				if cardInfo[0] == "Monsters" && Global.phase == 1:
					if Global.stackSize == 0 && cardInfo[5] == 0: # play active
						Global.stack[0] = cardInfo
						removeFromHand()
						stackPos = Global.stackSize
						startpos = position
						targetpos = activePos # position of active
						Global.stackSize += 1
						state = Played
					elif Global.stackSize <= 4:
						if cardInfo[5] == 0 && Global.stackSize <= 3:
							playMonsterStack()
						elif cardInfo[5] == 1:
							if Global.stackSize == 1:
								Global.sacrifice[0] = true
								playMonsterStack()
							elif Global.stackSize > 1:
								Global.sacReq = 1
								state = SacState
								Global.sacrificeState = true
						elif cardInfo[5] == 2:
							if Global.stackSize >= 2:
								Global.sacReq = 2
								state = SacState
								Global.sacrificeState = true
							
					else:
						pass
				elif cardInfo[0] == "Spells" && Global.phase == 1:
					# spell effect
					spellEffects()
					removeFromHand()
					moveD()
					position = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
				elif cardInfo[0] == "Arenas" && Global.phase == 1:
					if Global.arena:
						Global.arena = false
					removeFromHand()
					startpos = position
					targetpos = arenaPos # position of arena
					state = Played
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
		stat1 = str(cardInfo[3])
		stat2 = str(cardInfo[4])
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
	
	if fullname.length() > 14:
		$Bars/NameBar/Name/CenterContainer/Label.label_settings.font_size = 16
	$Bars/BottomBar/Element/CenterContainer/Label.text = element
	$Bars/BottomBar/Sacrifice/CenterContainer/Label.text = sacrifice
	$Bars/EffectBar/Effect/CenterContainer/Label.text = effect
	$Bars/NameBar/Name/CenterContainer/Label.text = fullname
	if cardInfo[0] == "Monsters":
		if state == InActive || state == InStack:
			$Bars/Stats/Stat1/CenterContainer/Label.text = str(cardInfo[3] + auraBuff[0] + Global.auraBuff[0][0] + Global.auraBuff[elements.find(element)][0])
			$Bars/Stats/Stat2/CenterContainer/Label.text = str(cardInfo[4] + auraBuff[1] + Global.auraBuff[0][1] + Global.auraBuff[elements.find(element)][1])
		else:
			$Bars/Stats/Stat1/CenterContainer/Label.text = str(cardInfo[3])
			$Bars/Stats/Stat2/CenterContainer/Label.text = str(cardInfo[4])
	else:
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
		Global.buffInfo = [-1, 4, 20, 0]
		allyBuff.emit()
	elif cardInfo[1] == "Veilex":
		Global.intel += Global.stackSize
	
func monsterAura():
	if cardInfo[1] == "Polarius":
		auraBuff[0] = (Global.stackSize - 1) * 10
	
func monsterDeathrite():
	if cardInfo[1] == "Goopa":
		Global.buffInfo = [-1, 4, 20, 0]
		allyBuff.emit()
	elif cardInfo[1] == "Opturtle":
		Global.draws += 1
	elif cardInfo[1] == "School":
		Global.intel += 1
		Global.draws += 1
	elif cardInfo[1] == "Brightmane Martyr":
		Global.intel += 1

func monsterOnKill():
	pass
	
func spellEffects():
	if cardInfo[1] == "Enrage": 
		Global.buffInfo = [0, 3, 25, 0]
		allyBuff.emit()
	elif cardInfo[1] == "Noxatu Ritual":
		if Global.stack[0].size() != 0:
			Global.sacrifice[Global.stackSize-1] = true
			Global.draws += 2
	elif cardInfo[1] == "Bleakfountain Pact":
		Global.buffInfo = [0, 3, 30 * Global.draws, 0]
		allyBuff.emit()
		Global.buffInfo = [0, 4, 30 * Global.draws, 0]
		allyBuff.emit()
		Global.draws = 0
	
func counterEffects():
	pass
	
func arena(action: String):
	if cardInfo[1] == "Flowerbeds":
		if action == "played":
			Global.auraBuff[0][1] += 30
		elif action == "destroyed":
			Global.auraBuff[0][1] -= 30
	if cardInfo[1] == "Hellfire Canyon":
		if action == "played":
			Global.auraBuff[0][0] += 20
		elif action == "destroyed":
			Global.auraBuff[0][0] -= 20
			
func dZoneAura(action: String):
	if cardInfo[1] == "Brightmane Martyr":
		if action == "sent":
			Global.auraBuff[5][0] += 40
		elif action == "removed":
			Global.auraBuff[5][0] -= 40
	
func destroy(): # destroy monster
	Global.sacrifice[stackPos] = false
	Global.stack[stackPos] = []
	Global.stackSize -= 1
	monsterDeathrite()
	moveD()
	#Global.dZone = cardInfo[1] # ALWAYS DO THIS BEFORE DISCARD
	#state = InDZone
	
func shiftUpStack():
	if stackPos != 0 && Global.stack[stackPos-1] == []:
		Global.stack[stackPos] = []
		stackPos -= 1
		Global.stack[stackPos] = cardInfo
		if stackPos == 0:
			state = InActive

func moveD():
	scale = Global.cardSize / size
	t = 0
	startpos = position
	targetpos = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
	state = SentDZone
