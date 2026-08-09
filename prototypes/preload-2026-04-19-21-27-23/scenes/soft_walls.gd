extends StaticBody3D

@onready var combiner = $CSGCombiner3D

var health = 100
func puncture(hit_pos: Vector3, dir: Vector3):
	var hole = CSGCylinder3D.new()
	hole.height = 5.0
	hole.radius = 0.25
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION

	combiner.add_child(hole)

	hole.global_position = hit_pos

	hole.look_at(hole.global_position + dir + Vector3.UP)
func die():
	health -= 10
	if health<= 0:
		self.queue_free()
