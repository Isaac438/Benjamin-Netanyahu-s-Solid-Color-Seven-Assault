extends Node3D

var speed = 200.0
var target_position: Vector3

func _process(delta):
	var dir = (target_position - global_position).normalized()
	global_position += dir * speed * delta

	if global_position.distance_to(target_position) < 0.5:
		queue_free()
