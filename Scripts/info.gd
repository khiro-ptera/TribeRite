extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(get_viewport().size) - size - Vector2(Global.cardSize.x, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"HBoxContainer/Info/Draws/CenterContainer/Label".text = "Draws: " + str(Global.draws)
	$"HBoxContainer/Info/Intel/CenterContainer/Label".text = "Intel: " + str(Global.intel)
