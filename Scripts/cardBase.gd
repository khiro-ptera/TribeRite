extends MarginContainer

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var cardName = "Flowerbeds"
@onready var cardIndex = cardDatabase[cardName]
@onready var cardInfo = cardDatabase.DATA[cardIndex]
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
var drawtime = 0.8
var handPos = 0
var stackPos = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Border.texture = load(borderImage)
	# $Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(cardImage)
	# var defaultScale = scale.x
	
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
			pass
		InStack:
			pass
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
			if cardInfo[0] == "Monsters" && Global.phase == 1:
				if Global.stackSize == 0: # play active
					Global.stack[0] = cardInfo[1]
					removeFromHand()
					stackPos = Global.stackSize
					startpos = position
					targetpos = activePos # position of active
					Global.stackSize += 1
					print(Global.stack)
					state = Played
				elif Global.stackSize <= 3:
					Global.stack[Global.stackSize] = cardInfo[1]
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
				Global.dZone = cardInfo[1]
				removeFromHand()
				state = InDZone
				position = Vector2($".".get_viewport().size) - size/1.25 - size*0.01
				
func removeFromHand():
	Global.hand[handPos] = false
	Global.handSize -= 1
	
