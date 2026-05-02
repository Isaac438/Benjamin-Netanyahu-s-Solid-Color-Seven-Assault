extends Node3D

func get_spawn():
	var spawns = $Spawns.get_children()
	return spawns[randi_range(0, spawns.size() - 1)]
