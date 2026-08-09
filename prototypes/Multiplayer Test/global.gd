extends Node

var players = []
var next_player_id = 1
var pause_menu: Control
var server_ip := "127.0.0.1"
var fps_counter := true
var my_id = null
var joining = false
var username = "67"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().process_frame
	pause_menu = get_tree().current_scene.find_child("PauseMenu", true, false)

	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	map_changed.emit(map)
var paused := false
var map := 0

signal map_changed(new_map)

func set_map(value: int):
	if map == value:
		return
	map = value
	map_changed.emit(map)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		toggle_pause()

func toggle_pause():
	paused = !paused
	get_tree().paused = paused

	pause_menu.visible = paused

	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
