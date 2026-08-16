extends Node

var PORT :int= global.port

var peer: ENetMultiplayerPeer

@onready var spawner: MultiplayerSpawner = get_node("/root/Main/MultiplayerSpawner")
@onready var map_root: Node3D = get_node("/root/Main/World/MapRoot")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

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

	map_root.send_current_map.rpc_id(
		id,
		map_root.current_map_id
	)

	spawner.spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)
	
@rpc("any_peer", "reliable")
func request_damage(target_path: NodePath, damage: int) -> void:
	if not multiplayer.is_server():
		return

	var target = get_node_or_null(target_path)

	if target == null:
		return

	if not target.is_in_group("destructible"):
		return

	print("DAMAGE REQUEST: ", target.name, " current health: ", target.health, " damage: ", damage)

	if target.has_method("die"):
		target.die(damage)

		print("AFTER DAMAGE: ", target.name, " health: ", target.health)
