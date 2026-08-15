extends StaticBody3D

@export var health := 100

func die(damage: int) -> void:
	if not multiplayer.is_server():
		return

	health -= damage

	if health <= 0:
		destroy.rpc()


@rpc("authority", "call_local", "reliable")
func destroy() -> void:
	queue_free()
