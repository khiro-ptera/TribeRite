extends TextureButton

var decksize = INF

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".scale *= Global.cardSize/$".".size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_released("leftclick"):
		if decksize > 0:
			decksize = $"../../".draw()
			if decksize == 0:
				disabled = true
