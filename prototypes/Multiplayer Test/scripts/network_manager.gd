extends Node

var PORT :int= global.port
var players: Dictionary = {}
var peer: WebSocketMultiplayerPeer

@onready var spawner: MultiplayerSpawner = get_node("/root/Main/MultiplayerSpawner")
@onready var map_root: Node3D = get_node("/root/Main/World/MapRoot")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_server() -> void:
	peer = WebSocketMultiplayerPeer.new()

	var error := peer.create_server(PORT)

	if error != OK:
		print("Server creation failed: ", error)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	players[1] = global.username

	print("Server started")

	spawner.spawn_player(1)

func start_client() -> void:
	peer = WebSocketMultiplayerPeer.new()

	var error := peer.create_client(
		"ws://" + global.server_ip + ":" + str(PORT)
	)

	if error != OK:
		print("Client creation failed: ", error)
		return

	multiplayer.multiplayer_peer = peer

	multiplayer.connected_to_server.connect(_on_connected_to_server)

	print("Client connecting...")

func _on_peer_connected(id: int) -> void:
	print("Peer connected: ", id)

	if id == multiplayer.get_unique_id():
		set_username.rpc_id(1, global.username)
		return

	if multiplayer.is_server():
		map_root.send_current_map.rpc_id(
			id,
			map_root.current_map_id
		)

		spawner.spawn_player(id)
	
@rpc("any_peer", "reliable")
func set_username(username: String) -> void:
	if not multiplayer.is_server():
		return

	var id := multiplayer.get_remote_sender_id()

	players[id] = username

	print("Player ", id, " username = ", username)

	update_players.rpc(players)
	
@rpc("authority", "reliable")
func update_players(updated_players: Dictionary) -> void:
	players = updated_players

	for player in get_tree().get_nodes_in_group("players"):
		var player_id := player.name.to_int()
		var label = player.get_node_or_null("UsernameLabel")

		if label:
			label.text = players.get(player_id, "Player")
			
func _on_connected_to_server() -> void:
	print("Connected to server")

	set_username.rpc_id(1, global.username)
	
func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected: ", id)

	players.erase(id)

	update_players.rpc(players)
	
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
