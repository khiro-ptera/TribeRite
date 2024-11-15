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
	BeneathDZone,
	Arena,
	SentDZone
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SacGradient.visible = false


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
	newCard.destroyArena.connect(destroyA)
	
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
	
func buffAlly(): # Global.buffInfo[0] == -1 means buff all
	for _i in $"Cards".get_children():
		if (_i.state == InStack || _i.state == InActive):
			if Global.buffInfo[0] == -1 || _i.stackPos == Global.buffInfo[0]:
				_i.cardInfo[Global.buffInfo[1]] += Global.buffInfo[2]
				
func destroyA(): 
	if Global.arena:
		print("DESTROY")
		for _i in $"Cards".get_children():
			print("getting...")
			if (_i.state == Arena):
				print("Destroying " + _i.cardInfo[1])
				_i.t = 0
				_i.startpos = _i.position
				_i.targetpos = Vector2(_i.get_viewport().size) - _i.size/1.25 - _i.size*0.01
				_i.state = SentDZone
				break
			

func startPhase():
	#once per turn effects
	pass
