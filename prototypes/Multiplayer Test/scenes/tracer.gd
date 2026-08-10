extends CharacterBody3D

var direction := Vector3.ZERO

@export var speed := 100.0
@export var lifetime := 5.0

var life_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	if !multiplayer.is_server():
		return

	velocity = direction * speed

	var collision := move_and_collide(velocity * delta)

	if collision:
		print("Bullet hit: ", collision.get_collider())
		queue_free()

	life_timer += delta

	if life_timer >= lifetime:
		queue_free()
