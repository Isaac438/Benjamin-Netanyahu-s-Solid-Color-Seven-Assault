extends Node3D

@export var hip_pos: Vector3 = Vector3(0.5, -0.4, -0.5)
@export var ads_pos: Vector3 = Vector3(0, -0.2, -0.3)
@export var ads_speed: float = 20.0

@onready var camera: Camera3D = get_parent()
var default_fov: float = 75.0
var ads_fov: float = 50.0

func _process(delta):
	var target_pos = hip_pos
	var target_fov = default_fov

	if Input.is_action_pressed("ads"): # Ensure "ads" is in your Input Map
		target_pos = ads_pos
		target_fov = ads_fov
	
	# Smoothly move weapon position
	transform.origin = transform.origin.lerp(target_pos, ads_speed * delta)
	# Smoothly adjust camera zoom
	camera.fov = lerp(camera.fov, target_fov, ads_speed * delta)
