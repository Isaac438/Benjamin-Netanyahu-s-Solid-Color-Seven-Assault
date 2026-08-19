extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func value_changed(value: float):
	if value == 1.0:
		text = "Native"
	else:
		text = str(value)
