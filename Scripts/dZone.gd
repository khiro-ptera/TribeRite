extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".position = Vector2($".".get_viewport().size) - $".".size
	$".".scale *= 1.05 * Global.cardSize/$".".size
