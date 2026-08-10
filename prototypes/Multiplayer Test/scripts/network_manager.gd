extends Node

const PORT := 42096

var peer: ENetMultiplayerPeer

@onready var spawner: MultiplayerSpawner = get_node("/root/Main/MultiplayerSpawner")
@onready var map_root: Node3D = get_node("/root/Main/World/MapRoot")


func start_server() -> void:
	peer = ENetMultiplayerPeer.new()

	var error := peer.create_server(PORT)

	if error != OK:
		print("Server creation failed: ", error)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	print("Server started")

	spawner.spawn_player(1)


func start_client() -> void:
	peer = ENetMultiplayerPeer.new()

	var error := peer.create_client(global.server_ip, PORT)

	if error != OK:
		print("Client creation failed: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Client connecting...")


func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)

	spawner.spawn_player(id)

	# Tell the new client which map we're currently on.
	map_root.send_current_map.rpc_id(
		id,
		map_root.current_map_id
	)


func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
