extends Node

var cardSize = Vector2(256, 480) * 0.6
var stackSize = 0
var handSize = 0
var maxHandSize = 5
var hand = [false, false, false, false, false, false, false, false]
var stack = ["", "", "", ""]
var phase = 1 # 0: Start Phase, 1: Play Phase, 2: Counter Phase, 3: Fight Phase, 4: End Phase
var dZone = ""
var draws = 5
var intel = 5
