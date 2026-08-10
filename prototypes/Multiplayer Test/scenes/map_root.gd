extends Node3D

@onready var map_root = self

var maps = [
	preload("res://scenes/oregani.tscn"),
	preload("res://scenes/island.tscn"),
	preload("res://scenes/debug_map.tscn"),
	preload("res://scenes/prison.tscn")
]

var current_map: Node = null

func _ready():
	global.map_changed.connect(_on_map_changed)

	# load starting map
	_on_map_changed(global.map)

func _on_map_changed(new_map: int):
	switch_to_map(new_map)

func switch_to_map(i: int):
	if i < 0 or i >= maps.size():
		return

	if current_map:
		current_map.queue_free()

	current_map = maps[i].instantiate()
	map_root.add_child(current_map, true)
