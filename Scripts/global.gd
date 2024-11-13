extends Node

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var cardSize = Vector2(256, 480) * 0.6
var stackSize = 0
var handSize = 0
var maxHandSize = 5
var hand = [false, false, false, false, false, false, false, false]
var stack = [[], [], [], []]
var phase = 1 # 0: Start Phase, 1: Play Phase, 2: Counter Phase, 3: Fight Phase, 4: End Phase
var dZone = ""
var draws = 50 # default 5
var intel = 1 # default 1
var playerTurn = true
var arenas = [[], []]
var sacrificeState = false
var sacrifice = [false, false, false, false]
