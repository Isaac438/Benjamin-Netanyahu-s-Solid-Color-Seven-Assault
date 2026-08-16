extends Node3D

var maps := [
	preload("res://scenes/oregani.tscn"),
	preload("res://scenes/island.tscn"),
	preload("res://scenes/debug_map.tscn"),
	preload("res://scenes/prison.tscn")
]

var current_map: Node = null
var current_map_id := 0
var changing_map := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if multiplayer.is_server():
		await switch_to_map(0)


func switch_to_map(i: int) -> void:
	if i < 0 or i >= maps.size():
		return

	if changing_map:
		while changing_map:
			await get_tree().process_frame

	changing_map = true

	if current_map:
		current_map.queue_free()
		await current_map.tree_exited
		current_map = null

	await get_tree().process_frame

	current_map = maps[i].instantiate()
	current_map.name = "CurrentMap"
	add_child(current_map, true)
	await get_tree().process_frame

	current_map_id = i
	changing_map = false

	print("Map ", i, " is ready.")
	
@rpc("any_peer", "reliable")
func request_map_change(i: int) -> void:
	if not multiplayer.is_server():
		return

	await switch_to_map(i)
	change_map.rpc(i)
	global.set_map(i)
	
@rpc("authority", "call_local", "reliable")
func change_map(i: int) -> void:
	if multiplayer.is_server():
		return

	await switch_to_map(i)

	global.set_map(i)
	
@rpc("authority", "reliable")
func send_current_map(i: int) -> void:
	print("Received current map: ", i)

	await switch_to_map(i)
