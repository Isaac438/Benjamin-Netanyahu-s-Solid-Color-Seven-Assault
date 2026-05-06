extends StaticBody3D
@export var FIRE_RATE = 0.2
var fire_timer := 0.0
var bullet_scene = preload("res://scenes/tracer.tscn")
var health = 10
func die():
	health -= 10
	if health<= 0:
		self.queue_free()
		
func _process(delta):
	fire_timer -= delta

	if fire_timer <= 0:
		shoot()
		fire_timer = FIRE_RATE

func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = global_position
	bullet.direction = -global_transform.basis.z
	bullet.add_collision_exception_with(self.get_node("."))
