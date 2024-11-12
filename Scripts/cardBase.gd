extends MarginContainer

@onready var cardDatabase = preload("res://Assets/Cards/CardsDatabase.gd")
var cardName = "Flowerbeds"
@onready var cardIndex = cardDatabase[cardName]
@onready var cardInfo = cardDatabase.DATA[cardIndex]
@onready var cardImage = str("res://Assets/Cards/" + cardInfo[0] + "/" + cardInfo[1] + ".png")
@onready var borderImage = str("res://Assets/Cards/templates/" + cardInfo[0] + ".png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(cardInfo)
	$Border.texture = load(borderImage)
	# $Border.scale *= size/$Border.texture.get_size()
	$Card.texture = load(cardImage)
	var stat1 = ""
	var stat2 = ""
	var element = ""
	var effect = ""
	var sacrifice = ""
	
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
	$Bars/NameBar/Name/CenterContainer/Label.text = cardName
	$Bars/Stats/Stat1/CenterContainer/Label.text = stat1
	$Bars/Stats/Stat2/CenterContainer/Label.text = stat2
	
