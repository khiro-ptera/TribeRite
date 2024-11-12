extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size.x = $".".get_viewport().size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match Global.phase:
		0:
			$"Phase".text = "Start Phase"
		1:
			$"Phase".text = "Play Phase"
		2:
			$"Phase".text = "Counter Phase"
		3:
			$"Phase".text = "Fight Phase"
		4:
			$"Phase".text = "End Phase"
