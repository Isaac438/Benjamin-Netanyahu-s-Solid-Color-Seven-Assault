extends LineEdit

func joined_server():
	editable = false

func text_changed(new_text: String):
	global.username = str(new_text)
