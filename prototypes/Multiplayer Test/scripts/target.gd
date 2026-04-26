extends MeshInstance3D
var health = 10
func die():
	health -= 10
	if health<= 0:
		self.queue_free()
