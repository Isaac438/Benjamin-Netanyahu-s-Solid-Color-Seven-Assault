extends LineEdit

func text_submitted(new_text: String):
	var width_number := int(new_text)
	
	# Optional: Prevent the window from breaking if the user typed letters or 0
	if width_number <= 0:
		return
		
	# Apply the new width
	var current_size = DisplayServer.window_get_size()
	DisplayServer.window_set_size(Vector2i(width_number, current_size.y))
