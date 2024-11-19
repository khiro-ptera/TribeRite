extends Node

# for card game
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
var sacReq = 0
var sacrifice = [false, false, false, false]
var buffInfo = [0, 0, 0, 0] # ally, stat, amount, type 
# for type, 0: all, 1: fire, 2: water, 3: earth, 4: electric, 5: steel, 6: sky, 7: magic
var auraBuff = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]] # atk, hp
var moving = false # if a card is moving, can't play other cards
var arena = false # true if there is an allied arena
var turn = 0

var oppDraws = 4
var oppIntel = 1
