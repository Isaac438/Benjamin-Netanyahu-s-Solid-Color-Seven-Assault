extends StaticBody3D
var health = 100
func die():
	health -= 10
	if health<= 0:
		self.queue_free()
