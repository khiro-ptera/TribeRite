extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".position = Vector2(0, -48)
	$".".size.x = 1.05 * Global.cardSize.x
	print($".".size.x)
	print(1.05 * Global.cardSize.x)
