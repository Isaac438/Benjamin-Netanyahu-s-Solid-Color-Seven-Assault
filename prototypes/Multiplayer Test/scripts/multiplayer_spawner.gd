extends MultiplayerSpawner

@export var network_player: PackedScene

func _ready() -> void:
	pass


func spawn_player(id: int) -> void:
	if !multiplayer.is_server():
		return

	# Don't spawn the same player twice.
	var existing_player := get_node_or_null(spawn_path).get_node_or_null(str(id))

	if existing_player:
		return

	var player := network_player.instantiate()

	player.name = str(id)

	get_node(spawn_path).add_child(player, true)
