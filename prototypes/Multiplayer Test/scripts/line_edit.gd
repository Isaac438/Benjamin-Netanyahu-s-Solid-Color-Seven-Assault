extends LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_text_changed(new_text: String) -> void:
	global.server_ip = new_text
	print("server_ip changed to ", new_text)
