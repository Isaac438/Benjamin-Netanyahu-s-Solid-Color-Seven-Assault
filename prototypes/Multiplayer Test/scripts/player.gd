extends CharacterBody3D

@onready var camera: Camera3D = $camera
@onready var raycast: RayCast3D = $camera/RayCast3D
@onready var collider = $CollisionShape3D
@onready var mesh = $MeshInstance3D
@onready var bullet_spawner: MultiplayerSpawner = get_node("/root/Main/BulletSpawner")
@onready var net = get_node("/root/Main/NetworkManager")

@export var max_health := 100
@export var health: int = 100
@export var bullet_spawn_distance := 1.0
@export var FIRE_RATE := 0.1

var lean_state := 0
var lean_amount := 0.0
var target_lean := 0.0
var crouch_state := false
var prone_state := false

const LEAN_ANGLE = 15.0
const LEAN_OFFSET = 0.3
const LEAN_SPEED = 10.0
const SPEED = 5.0
const CROUCH_SPEED = 3.0
const SPRINT_SPEED = 8.0
const PRONE_SPEED = 2.0
const JUMP_VELOCITY = 4.5 * 2
const MOUSE_SENS = 0.002
const STAND_HEIGHT = 1.8
const CROUCH_HEIGHT = 1.5
const PRONE_HEIGHT = 1.0

var just_teleported := true
var fire_timer := 0.0
var bullet_scene = preload("res://scenes/tracer.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not is_multiplayer_authority():
		camera.current = false
		return

	global.map_changed.connect(teleport)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	_initial_spawn()

func _initial_spawn() -> void:
	print(name, " starting initial spawn")

	var map_root = get_node("/root/Main/World/MapRoot")

	while map_root.current_map == null:
		await get_tree().process_frame

	await get_tree().process_frame

	_do_teleport()

func teleport(_new_map: int) -> void:
	just_teleported = true
	call_deferred("_do_teleport")
	
@rpc("any_peer", "reliable")
func request_spawn() -> void:
	if multiplayer.get_remote_sender_id() != 1:
		return

	if not is_multiplayer_authority():
		return

	print("Spawn request received by ", name)

	await _do_teleport()
	
func _do_teleport() -> void:
	var map_root = get_node("/root/Main/World/MapRoot")

	print(name, " looking for current map")

	while map_root.current_map == null or map_root.changing_map:
		await get_tree().process_frame

	var map = map_root.current_map

	print(name, " found map: ", map.name)

	await get_tree().process_frame

	if not is_instance_valid(map):
		print("Map was freed before spawn!")
		return

	var raw_spawns = map.find_children(
		"*SpawnPoint*",
		"",
		true,
		false
	)

	var valid_spawns := []

	for node in raw_spawns:
		if node is Marker3D:
			valid_spawns.append(node)

	print(
		name,
		" found ",
		valid_spawns.size(),
		" spawn points"
	)

	if valid_spawns.is_empty():
		print("WARNING: No spawn points found in ", map.name)
		return

	var spawn = valid_spawns[
		randi_range(0, valid_spawns.size() - 1)
	]

	global_position = spawn.global_position
	velocity = Vector3.ZERO
	health = max_health

	print(
		name,
		" spawned at ",
		spawn.name,
		" ",
		spawn.global_position
	)
	
func die(damage: int) -> void:
	if not multiplayer.is_server():
		return
	print(
	name,
	" | server: ",
	multiplayer.is_server(),
	" | health: ",
	health
)
	health -= damage

	print(name, " health: ", health)

	if health <= 0:
		print(name, " died")

		health = max_health

		var authority := get_multiplayer_authority()

		if authority == multiplayer.get_unique_id():
			respawn()
		else:
			respawn.rpc_id(authority)

@rpc("any_peer", "reliable")
func respawn() -> void:
	if multiplayer.get_remote_sender_id() != 1 and multiplayer.get_unique_id() != 1:
		return

	if not is_multiplayer_authority():
		return

	print(name, " respawning")

	health = max_health
	velocity = Vector3.ZERO

	await _do_teleport()

func _input(event) -> void:
	if not is_multiplayer_authority():
		return
	if get_tree().paused:
		return
	if event.is_action_pressed("e"):
		if lean_state == -1:
			lean_state = 0
		else:
			lean_state = -1

	elif event.is_action_pressed("q"):
		if lean_state == 1:
			lean_state = 0
		else:
			lean_state = 1

	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * MOUSE_SENS)

			camera.rotate_x(
				-event.relative.y * MOUSE_SENS
			)

			camera.rotation.x = clampf(
				camera.rotation.x,
				-deg_to_rad(90),
				deg_to_rad(90)
			)
			
	if event.is_action_pressed("c"):
		if prone_state == true and crouch_state == false:
			prone_state = false
		crouch_state = !crouch_state
		
	if event.is_action_pressed("prone"):
		if crouch_state == true and prone_state == false:
			crouch_state = false
		prone_state = !prone_state
	
	

func spawn_at_point() -> void:
	if not is_multiplayer_authority():
		return

	print("spawn_at_point called for ", name)

	_do_teleport()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if not is_on_floor():
		velocity += get_gravity() * delta * 3.0
	if get_tree().paused == false:
		if Input.is_action_pressed("space") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		elif crouch_state == true and prone_state == false:
			collider.shape.height = lerp(
				collider.shape.height,
				CROUCH_HEIGHT,
				10 * delta)
			mesh.scale.y = lerp(
				mesh.scale.y,
				CROUCH_HEIGHT / 2.0,
				10 * delta)
				
			camera.position.y = lerp(
				camera.position.y,
				1.0,
				10 * delta
			)
			
		elif prone_state == true and crouch_state == false:
			collider.rotation.x = lerp(
				collider.rotation.x,
				deg_to_rad(-90.0),
				10 * delta
			)
			
			mesh.rotation.x = lerp(
				mesh.rotation.x,
				deg_to_rad(-90.0),
				10 * delta
			)
			
			camera.position.y = lerp(
				camera.position.y,
				PRONE_HEIGHT,
				10 * delta
			)
			
			camera.position.z = lerp(
				camera.position.z,
				-0.75,
				10 * delta
			)
		else:
			collider.shape.height = STAND_HEIGHT
			collider.rotation.x = lerp(
				collider.rotation.x,
				deg_to_rad(0.0),
				10 * delta
			)
			
			mesh.rotation.x = lerp(
				mesh.rotation.x,
				deg_to_rad(0.0),
				10 * delta
			)
			mesh.scale.y = 1.0
			camera.position.y = lerp(
				camera.position.y,
				1.6,
				10 * delta
			)
		
		var input_dir := Input.get_vector(
			"a",
			"d",
			"w",
			"s"
		)

		var direction := (
			transform.basis *
			Vector3(input_dir.x, 0, input_dir.y)
		).normalized()
		
		if direction and prone_state:
			velocity.x = direction.x * PRONE_SPEED
			velocity.z = direction.z * PRONE_SPEED

		elif direction and Input.is_action_pressed("sprint") and crouch_state:
			velocity.x = direction.x * CROUCH_SPEED
			velocity.z = direction.z * CROUCH_SPEED

		elif direction and Input.is_action_pressed("sprint"):
			velocity.x = direction.x * SPRINT_SPEED
			velocity.z = direction.z * SPRINT_SPEED

		elif direction and crouch_state:
			velocity.x = direction.x * CROUCH_SPEED
			velocity.z = direction.z * CROUCH_SPEED

		elif direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED

		else:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
		

func _enter_tree() -> void:
	add_to_group("players")

	var id := name.to_int()

	set_multiplayer_authority(id)

	print(
		"Player ",
		name,
		" authority = ",
		get_multiplayer_authority(),
		" local peer = ",
		multiplayer.get_unique_id()
	)
func _on_death_plane_body_entered(body: Node3D) -> void:
	if body == self and multiplayer.is_server():
		die(10000)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if get_tree().paused:
		return
	target_lean = lean_state

	lean_amount = lerp(
		lean_amount,
		target_lean,
		LEAN_SPEED * delta
	)

	apply_lean()

	fire_timer -= delta

	if Input.is_action_pressed("shoot") and fire_timer <= 0:
		shoot()
		fire_timer = FIRE_RATE


func shoot() -> void:
	var direction := -camera.global_transform.basis.z

	var spawn_position := (
		camera.global_position +
		direction * bullet_spawn_distance
	)

	request_shoot.rpc(
		spawn_position,
		direction
	)


func apply_lean() -> void:
	rotation_degrees.z = lean_amount * LEAN_ANGLE


@rpc("any_peer", "call_local", "reliable")
func request_shoot(
	position: Vector3,
	direction: Vector3
) -> void:
	if not multiplayer.is_server():
		return

	print("Server received shot from: ", name)

	bullet_spawner.spawn({
		"position": position,
		"direction": direction
	})
