extends MultiplayerSpawner

var bullet_scene := preload("res://scenes/tracer.tscn")


func _ready() -> void:
	spawn_function = _spawn_bullet


func _spawn_bullet(data: Dictionary) -> Node:
	var bullet = bullet_scene.instantiate()

	bullet.position = data["position"]
	bullet.direction = data["direction"]

	return bullet
