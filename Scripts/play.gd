extends Node2D

const cardBase = preload("res://Scenes/Cards/CardBase.tscn")
const deck = preload("res://Scripts/deck.gd")
var selected = []
@onready var decksize = deck.decklist.size()
@onready var starthand = Vector2($".".get_viewport().size) * Vector2(0.2, 1.0)
@onready var handX = $".".get_viewport().size.x * 0.4
@onready var elements = ["All", "Fire", "Water", "Earth", "Electric", "Steel", "Sky", "Magic"]


enum{
	InHand, 
	InActive, 
	InStack, 
	InDZone,
	Drawn,
	FocusInHand,
	BeneathDZone,
	Arena,
	SentDZone
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SacGradient.visible = false
	Global.playerTurn = true
	Global.phase = 0
	$PhaseButton/Label.size = $PhaseButton.size
	$PhaseButton/Label.text = "Next Phase"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.sacrificeState:
		$SacGradient.visible = true
	else:
		$SacGradient.visible = false

func draw():
	var newCard = cardBase.instantiate()
	newCard.visible = false
	selected = randi() % decksize
	newCard.cardName = deck.decklist[selected]
	$Cards.add_child(newCard)
	
	newCard.allyBuff.connect(buffAlly)
	
	newCard.scale *= Global.cardSize/newCard.size
	newCard.ogScalex = newCard.scale.x
	newCard.startpos = Vector2(0, $".".get_viewport().size.y) + Vector2(0, -newCard.size.y/1.25)
	newCard.state = Drawn
	if Global.handSize < Global.maxHandSize:
		Global.draws -= 1
		newCard.handPos = Global.handSize
		Global.hand[newCard.handPos] = true
		newCard.targetpos = starthand - newCard.size/2 + Vector2(Global.handSize * newCard.size.x * (4.0/Global.maxHandSize), -20)
		deck.decklist.remove_at(selected)
		decksize -= 1
		Global.handSize += 1
	else:
		newCard.targetpos = Vector2($".".get_viewport().size) - newCard.size/1.25 - newCard.size*0.01
		deck.decklist.remove_at(selected)
		decksize -= 1
	return decksize
	
func nextPhase():
	Global.phase += 1
	if Global.playerTurn:
		if Global.phase == 0:
			# TODO: process start of turn effects
			pass
		elif Global.phase == 2:
			$PhaseButton/Label.text = "Opponent Countering"
			$PhaseButton.disabled = true
		elif Global.phase == 3:
			$PhaseButton/Label.text = "Next Phase"
			$PhaseButton.disabled = false
			# TODO: process fight
		elif Global.phase == 4:
			# TODO: process end of turn effects
			$PhaseButton/Label.text = "End Turn"
		elif Global.phase == 5:
			$PhaseButton/Label.text = "Opponent's turn"
			Global.phase = 0
			Global.playerTurn = false
	if !Global.playerTurn && Global.phase == 5:
		$PhaseButton/Label.text = "Next Phase"
		Global.phase = 0
		Global.playerTurn = true
	return Global.playerTurn
		
		
	
func buffAlly(): # Global.buffInfo[0] == -1 means buff all
	for _i in $"Cards".get_children():
		if (_i.state == InStack || _i.state == InActive) && (_i.cardInfo[2] == elements[Global.buffInfo[3]] || Global.buffInfo[3] == 0):
			if Global.buffInfo[0] == -1 || _i.stackPos == Global.buffInfo[0]:
				_i.cardInfo[Global.buffInfo[1]] += Global.buffInfo[2]
			

func startPhase():
	#once per turn effects
	pass
