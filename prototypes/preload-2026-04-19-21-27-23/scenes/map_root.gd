extends Node3D

var maps = [
	preload("res://scenes/oregani.tscn"),
	preload("res://scenes/island.tscn"),
	preload("res://scenes/debug_map.tscn")
]

var current_map: Node = null
var index := 1

func _ready():
	switch_to_map(1) # start on island if you want

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		index = (index + 1) % maps.size()
		switch_to_map(index)

func switch_to_map(i: int):
	if current_map:
		current_map.queue_free()

	current_map = maps[i].instantiate()
	add_child(current_map)
