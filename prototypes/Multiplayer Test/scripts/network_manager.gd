extends Node

var my_id = str(OS.get_unique_id())
var ws := WebSocketPeer.new()
var players := {} # id -> node reference


func _ready():
	ws.connect_to_url("ws://127.0.0.1:3000")

func _process(delta):
	ws.poll()

	while ws.get_available_packet_count() > 0:
		var msg = ws.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(msg)

		handle_packet(data)

func spawn_remote_player(id):
	var player_scene = preload("res://scenes/player.tscn")
	var p = player_scene.instantiate()
	get_tree().current_scene.add_child(p)

	players[id] = p

func send_position(id, pos: Vector3):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return

	ws.send_text(JSON.stringify({
		"type": "update",
		"id": id,
		"pos": [pos.x, pos.y, pos.z]
	}))
func send_hit(target_path):
	if ws.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
		
	ws.send_text(JSON.stringify({
		"type": "hit",
		"target": str(target_path)
	}))
func handle_packet(data):
	if data["type"] == "update":
		var id = data["id"]
		if id == my_id:
			return
		var pos = Vector3(data["pos"][0], data["pos"][1], data["pos"][2])

		if not players.has(id):
			spawn_remote_player(id)

		players[id].global_position = pos
