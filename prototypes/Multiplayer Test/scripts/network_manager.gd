extends Node

var players_node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_on_peer_connected)

	await get_tree().process_frame
	players_node = get_tree().current_scene.get_node("World/Players")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_H:
			host()

		if event.keycode == KEY_J:
			join("127.0.0.1")
			

func host():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	var peer = ENetMultiplayerPeer.new()
	peer.create_server(7777)
	multiplayer.multiplayer_peer = peer

	# spawn server player
	spawn_player.rpc(multiplayer.get_unique_id())

func join(ip):
	print("Joining...")
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 7777)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id):
	print("peer connected", id)
	if multiplayer.is_server():
		spawn_player(id)

@rpc("authority", "call_local")
func spawn_player(id):
	var player = preload("res://scenes/player.tscn").instantiate()
	player.name = str(id)

	players_node.add_child(player)
	player.set_multiplayer_authority(id)
