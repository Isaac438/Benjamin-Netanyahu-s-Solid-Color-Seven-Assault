extends CharacterBody3D

@onready var camera: Camera3D = $camera
@onready var raycast: RayCast3D = $camera/RayCast3D
@onready var collider = $CollisionShape3D
@onready var bullet_spawner: MultiplayerSpawner = get_node("/root/Main/BulletSpawner")
@export var max_health := 100
@export var health := max_health

const SPEED = 5.0
const CROUCH_SPEED = 3.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5 * 2
const MOUSE_SENS = 0.002
const STAND_HEIGHT = 1.8
const CROUCH_HEIGHT = 1.35
@export var FIRE_RATE = 0.1  # seconds between shots

var just_teleported := true
var net_timer := 0.0
var fire_timer := 0.0
var bullet_scene = preload("res://scenes/tracer.tscn")

func _input(event):
	# FIX: If we don't own this player, don't let our mouse rotate them!
	if !is_multiplayer_authority(): 
		return
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENS)
		camera.rotate_x(-event.relative.y * MOUSE_SENS)
		camera.rotation.x = clampf(camera.rotation.x,-deg_to_rad(90), deg_to_rad(90))

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func take_damage(amount: int) -> void:
	if !multiplayer.is_server():
		return

	health -= amount

	print(name, " health: ", health)

	if health <= 0:
		die()

func die() -> void:
	if !multiplayer.is_server():
		return

	health = max_health

	# Respawn instead of reloading the entire scene.
	call_deferred("_respawn")

func _respawn() -> void:
	_do_teleport()

func _ready():
	if not is_multiplayer_authority():
		camera.current = false 
		return
		
	if has_node("MultiplayerSynchronizer"):
		await $MultiplayerSynchronizer.ready
		$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())

	global.map_changed.connect(teleport)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# FIX: If we just spawned and can't find a map, wait for it!
	call_deferred("initial_spawn_check")

func initial_spawn_check():
	var map_root = get_tree().current_scene.find_child("MapRoot", true, false)
	
	# If the map node doesn't exist yet, wait half a second and try again
	if not map_root or map_root.get_child_count() == 0:
		print("Client is waiting for world map to replicate...")
		await get_tree().create_timer(0.5).timeout
		initial_spawn_check() # Retry
	else:
		# Map exists! Safe to teleport to a spawn point
		_do_teleport()

func teleport(_new_map):
	call_deferred("_do_teleport")
	just_teleported = true
func _do_teleport():
	await get_tree().process_frame
	await get_tree().process_frame # important
	
	var map_root = get_tree().current_scene.find_child("MapRoot", true, false)
	if not map_root or map_root.get_child_count() == 0:
		return
		
	var map = map_root.get_child(0)
	
	# Find children matching the wildcard pattern
	var raw_spawns = map.find_children("*SpawnPoint*", "", true, false)
	var valid_spawns = []
	
	# FILTER: Only keep actual 3D physical positions, ignore Spawns/Spawners
	for node in raw_spawns:
		if node is Node3D and not node is MultiplayerSpawner:
			valid_spawns.append(node)
			
	print("Valid spawn points found: ", valid_spawns.size())
	
	if valid_spawns.size() > 0:
		var spawn = valid_spawns[randi_range(0, (valid_spawns.size() - 1))]
		global_position = spawn.global_position
		velocity = Vector3.ZERO
		just_teleported = false
	else:
		print("CRITICAL: No valid physical Node3D spawn points found!")


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2.71828182845904523536

	if Input.is_action_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var crouching := Input.is_action_pressed("KEY_C")
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
		_respawn()
	
func _process(delta):
	if just_teleported:
		return
	var move = Vector3()
	net_timer -= delta
	
	if net_timer <= 0:
		#net.send_position(player_id, global_position)
		net_timer = 0.05 # 20 updates/sec
		
	global_position += move * 5 * delta
	fire_timer -= delta

	if Input.is_action_pressed("shoot") and fire_timer <= 0:
		shoot()
		fire_timer = FIRE_RATE

func shoot() -> void:
	request_shoot.rpc(
		camera.global_position,
		-camera.global_transform.basis.z
	)

@rpc("any_peer", "reliable")
func request_shoot(position: Vector3, direction: Vector3) -> void:
	print("SERVER RECEIVED SHOOT")

	if !multiplayer.is_server():
		return

	print("SERVER SPAWNING BULLET")

	bullet_spawner.spawn({
		"position": position,
		"direction": direction
	})
@onready var net = get_node("/root/Main/NetworkManager")
