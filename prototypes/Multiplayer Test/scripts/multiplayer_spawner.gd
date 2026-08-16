extends MultiplayerSpawner

@export var network_player: PackedScene


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func spawn_player(id: int) -> void:
	if not multiplayer.is_server():
		return

	var spawn_root := get_node(spawn_path)

	if spawn_root.has_node(str(id)):
		return

	print("Spawning player ", id)

	var player := network_player.instantiate()
	player.name = str(id)

	spawn_root.add_child(player, true)

	print(
		"Player ",
		id,
		" added. Authority = ",
		player.get_multiplayer_authority()
	)

	await get_tree().process_frame

	if id == 1:
		await player._do_teleport()
	else:
		player.request_spawn.rpc_id(id)
		
