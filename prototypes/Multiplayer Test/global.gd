extends Node

var players = []
var next_player_id = 1

var pause_menu: Control
var port = 42069
var server_ip := "127.0.0.1"
var fps_counter := true
var my_id = null
var joining := false
var username = "67"

var paused := false
var map := 0

signal map_changed(new_map)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	await get_tree().process_frame

	pause_menu = get_tree().current_scene.find_child(
		"PauseMenu",
		true,
		false
	)

	if pause_menu:
		pause_menu.visible = false
		pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	toggle_pause()

func set_map(value: int) -> void:
	map = value
	map_changed.emit(value)


func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			toggle_pause()


func toggle_pause() -> void:
	paused = !paused
	get_tree().paused = paused

	if pause_menu:
		pause_menu.visible = paused

	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
