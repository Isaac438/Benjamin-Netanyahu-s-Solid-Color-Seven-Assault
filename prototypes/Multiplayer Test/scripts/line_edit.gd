extends LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_text_changed(new_text: String) -> void:
	global.port = new_text
	print("port changed to ", new_text)
