extends Node

@onready var players_node = get_tree().current_scene.get_node("World/Players")

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(id):
	if multiplayer.is_server():
		spawn_player(id)

func spawn_player(id):
	var player = preload("res://scenes/player.tscn").instantiate()
	player.name = str(id)
	players_node.add_child(player)
	player.set_multiplayer_authority(id)
