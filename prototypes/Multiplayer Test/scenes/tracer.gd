extends Area3D

var direction := Vector3.ZERO
var speed := 100.0


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
