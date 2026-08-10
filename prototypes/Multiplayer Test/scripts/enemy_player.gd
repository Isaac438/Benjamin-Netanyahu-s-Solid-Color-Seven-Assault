extends CharacterBody3D

var id = 1000

func _process(delta: float) -> void:
	global_position = global.players[id]
