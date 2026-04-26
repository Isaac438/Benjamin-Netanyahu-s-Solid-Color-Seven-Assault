extends CharacterBody3D

var speed = 50.0
var direction = Vector3.ZERO

func _physics_process(delta):
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)
	if collision:
		var body = collision.get_collider()
		if body.get_parent().has_method("die"):
			body.get_parent().die()
		queue_free()
	await get_tree().create_timer(3).timeout
	queue_free()
