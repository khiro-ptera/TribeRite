extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_released("leftclick"):
		if !Global.sacrificeState && Global.playerTurn:
			if !$"../".nextPhase():
				disabled = true
			else: 
				disabled = false
