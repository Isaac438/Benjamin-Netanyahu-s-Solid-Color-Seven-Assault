extends CharacterBody3D

var direction := Vector3.ZERO
@onready var net = get_node("/root/Main/NetworkManager")
@export var speed := 100.0
@export var lifetime := 5.0
@onready var raycast: RayCast3D = $RayCast3D
var life_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	raycast.target_position = direction * 2.0
	raycast.enabled = true

func _physics_process(delta: float) -> void:
	velocity = direction * speed

	if multiplayer.is_server():
		raycast.target_position = direction * (speed * delta)
		raycast.force_raycast_update()

		if raycast.is_colliding():
			var hit = raycast.get_collider()

			if hit.is_in_group("destructible"):
				net.request_damage(hit.get_path(), 25)

			queue_free()
			return

	move_and_slide()
