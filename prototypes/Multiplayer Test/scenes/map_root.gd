extends Node3D

var maps := [
	preload("res://scenes/oregani.tscn"),
	preload("res://scenes/island.tscn"),
	preload("res://scenes/debug_map.tscn"),
	preload("res://scenes/prison.tscn")
]

var current_map: Node = null
var current_map_id := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if multiplayer.is_server():
		switch_to_map(0)


func switch_to_map(i: int) -> void:
	if i < 0 or i >= maps.size():
		return

	print("Switching local map to: ", i)

	if current_map:
		current_map.queue_free()
		await current_map.tree_exited

	current_map = maps[i].instantiate()
	current_map.name = "CurrentMap"
	add_child(current_map, true)

	current_map_id = i
	global.set_map(i)


func request_map_change(i: int) -> void:
	if !multiplayer.is_server():
		return

	if i < 0 or i >= maps.size():
		return

	# The server changes its own map.
	switch_to_map(i)

	# Tell every client to change theirs.
	change_map.rpc(i)


@rpc("authority", "call_local", "reliable")
func change_map(i: int) -> void:
	print("RPC: changing map to ", i)

	# The server already changed its map above.
	# Clients execute this function.
	if multiplayer.is_server():
		return

	switch_to_map(i)


@rpc("authority", "reliable")
func send_current_map(i: int) -> void:
	print("Received current map: ", i)
	switch_to_map(i)
