extends HTTPRequest

var server_url = "http://" + global.server_ip + ":8000"
var timer = 0.0
@onready var local_player = get_node("/root/Main/player")
func _process(delta: float) -> void:
	timer+=delta
	if timer == 1.0:
		if global.joining == true:
			join_server(global.username, local_player.global_position)
			timer = 0.0
			global.joining = false

func join_server(player_name: String, position: Vector3):
	var server_url = "http://" + global.server_ip + ":8000"
	var data = JSON.stringify({
		"name": player_name,
		"position": {
			"x": position.x,
			"y": position.y,
			"z": position.z
		}
	})

	request(
		server_url + "/join",
		["Content-Type: application/json"],
		HTTPClient.METHOD_POST,
		data
	)
func _on_http_request_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	var response = JSON.parse_string(body.get_string_from_utf8())
	if response.has("id"):
		global.my_id = response["id"]
	print(response)
	
func send_position(id, pos):
	pass

func send_hit(path):
	pass

func add_player():
	var player = {
		"id": global.next_player_id,
		#"name": player_name
	}

	global.players.append(player)
	global.next_player_id += 1

	return player["id"]
