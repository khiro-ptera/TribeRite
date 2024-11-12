extends Node2D

const cardBase = preload("res://Scenes/Cards/CardBase.tscn")
const deck = preload("res://Scripts/deck.gd")
var selected = []
var handsize = 0
var maxHandsize = 5
@onready var decksize = deck.decklist.size()
@onready var starthand = Vector2($".".get_viewport().size) * Vector2(0.2, 1.0)
@onready var handX = $".".get_viewport().size.x * 0.4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw():
	var newCard = cardBase.instantiate()
	selected = randi() % decksize
	newCard.cardName = deck.decklist[selected]
	$Cards.add_child(newCard)
	# newCard.position = $"Deck/DeckDraw".position
	if handsize < 5:
		print(maxHandsize)
		newCard.position = starthand - newCard.size/2 + Vector2(handsize * newCard.size.x * (4.0/maxHandsize), 0)
		newCard.scale *= Global.cardSize/newCard.size
		deck.decklist.remove_at(selected)
		decksize -= 1
		handsize += 1
		print(deck.decklist)
	else:
		newCard.position = Vector2($".".get_viewport().size) - newCard.size/1.25 - newCard.size*0.01
		newCard.scale *= Global.cardSize/newCard.size
		deck.decklist.remove_at(selected)
		decksize -= 1
		print(deck.decklist)
	return decksize
