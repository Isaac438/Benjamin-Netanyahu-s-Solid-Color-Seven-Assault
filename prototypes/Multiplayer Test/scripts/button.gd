extends Button


func _on_server_pressed() -> void:
	NetworkManager.start_server()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_client_pressed() -> void:
	NetworkManager.start_client()
