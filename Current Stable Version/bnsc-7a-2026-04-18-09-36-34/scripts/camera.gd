extends Camera3D

@onready var raycast = $RayCast3D
var tracer_scene = preload("res://scenes/tracer.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	raycast.force_raycast_update()
	
	var origin = global_position
	var hit_position = raycast.target_position

	if raycast.is_colliding():
		var target = raycast.get_collider()
		hit_position = raycast.get_collision_point()

		if target.get_parent().has_method("die"):
			target.get_parent().die()

	# spawn tracer
	spawn_tracer(origin, hit_position)

func spawn_tracer(start_pos: Vector3, target_pos: Vector3):
	var tracer = tracer_scene.instantiate()
	get_tree().current_scene.add_child(tracer)

	tracer.global_position = start_pos
	tracer.target_position = target_pos
	tracer.look_at(target_pos)
