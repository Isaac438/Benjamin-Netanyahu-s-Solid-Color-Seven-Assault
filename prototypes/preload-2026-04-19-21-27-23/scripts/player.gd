extends CharacterBody3D

@onready var camera: Camera3D = $camera
@onready var raycast: RayCast3D = $camera/RayCast3D
@onready var collider = $CollisionShape3D

const SPEED = 5.0
const CROUCH_SPEED = 3.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5 * 2
const MOUSE_SENS = 0.002
const STAND_HEIGHT = 1.8
const CROUCH_HEIGHT = 1.35
@export var FIRE_RATE = 0.2  # seconds between shots

var fire_timer := 0.0
var bullet_scene = preload("res://scenes/tracer.tscn")

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clampf(camera.rotation.x,-deg_to_rad(90), deg_to_rad(90))

func _ready():
	global.map_changed.connect(teleport)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func teleport(new_map):
	call_deferred("_do_teleport")
func _do_teleport():
	await get_tree().process_frame
	await get_tree().process_frame  # important

	var map_root = get_tree().current_scene.get_node("MapRoot")
	var map = map_root.get_child(0)
	var spawn = map.find_child("SpawnPoint", true, false)

	if spawn:
		global_transform.origin = spawn.global_transform.origin
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * PI

	if Input.is_action_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var crouching: bool
	if Input.is_action_pressed("c"):
		collider.shape.height = CROUCH_HEIGHT
		camera.position.y = lerp(camera.position.y, 1.0, 10 * delta)
	else:
		collider.shape.height = STAND_HEIGHT
		camera.position.y = lerp(camera.position.y, 1.6, 10 * delta)
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and Input.is_action_pressed("sprint"):
		velocity.x = direction.x * SPRINT_SPEED
		velocity.z = direction.z * SPRINT_SPEED
	elif direction and crouching:
		velocity.x = direction.x * CROUCH_SPEED
		velocity.z = direction.z * CROUCH_SPEED
		collider.shape.height = CROUCH_HEIGHT
		camera.position.y = lerp(camera.position.y, 1.0, 10 * delta)
	elif direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
		

	move_and_slide()

func _on_death_plane_body_entered(body: Node3D) -> void:
	if body == self:
		get_tree().reload_current_scene()
	
func _process(delta):
	fire_timer -= delta

	if Input.is_action_pressed("shoot") and fire_timer <= 0:
		shoot()
		fire_timer = FIRE_RATE

func shoot():
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = camera.global_position
	bullet.direction = -camera.global_transform.basis.z
	bullet.add_collision_exception_with(self)
