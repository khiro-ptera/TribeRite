extends Node2D

const cardBase = preload("res://Scenes/Cards/CardBase.tscn")
const deck = preload("res://Scripts/deck.gd")
var selected = []
@onready var decksize = deck.decklist.size()
@onready var starthand = Vector2($".".get_viewport().size) * Vector2(0.2, 1.0)
@onready var handX = $".".get_viewport().size.x * 0.4

enum{
	InHand, 
	InActive, 
	InStack, 
	InDZone,
	Drawn,
	FocusInHand,
	BeneathDZone
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw():
	var newCard = cardBase.instantiate()
	newCard.visible = false
	selected = randi() % decksize
	newCard.cardName = deck.decklist[selected]
	$Cards.add_child(newCard)
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

func startPhase():
	#once per turn effects
	pass
