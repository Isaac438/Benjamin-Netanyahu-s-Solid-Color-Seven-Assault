extends MultiplayerSpawner

@export var bullet_scene: PackedScene


func _ready() -> void:
	spawn_function = _spawn_bullet


func _spawn_bullet(data: Dictionary) -> Node:
	var bullet := bullet_scene.instantiate()

	bullet.global_position = data["position"]
	bullet.direction = data["direction"]

	return bullet
