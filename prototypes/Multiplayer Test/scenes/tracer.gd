extends CharacterBody3D

var speed = 50.0
var direction = Vector3.ZERO

func _physics_process(delta):
	var from = global_position
	var to = from + direction * speed * delta
	
	var space = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]  # optional: ignore the bullet itself
	
	var result = space.intersect_ray(query)
	
	if result:
		var body = result.collider
	
		if body.has_method("die"):
			body.die()
			queue_free()
		elif body.has_method("puncture"):
			body.puncture(global_position)
		else:
	    	queue_free()
	else:
	    global_position = to
