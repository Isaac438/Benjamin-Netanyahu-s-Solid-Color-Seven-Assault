# network_manager.gd
extends Node # Changed from HTTPRequest if you aren't using HTTP anymore

const PORT: int = 42096
var peer: ENetMultiplayerPeer
@onready var spawner: MultiplayerSpawner = get_node("/root/Main/MultiplayerSpawner")
func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started")
	
	# The host is peer ID 1. They need a player spawned for them manually:
	# (Replace $MultiplayerSpawner with the real path to your spawner node)
	spawner.spawn_player(1) 

func start_client() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(global.server_ip, PORT) # Don't hardcode localhost
	multiplayer.multiplayer_peer = peer
	print("Client connecting...")
