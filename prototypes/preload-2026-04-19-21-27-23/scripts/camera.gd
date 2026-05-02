extends Camera3D

var lean_state := 0  # -1 = left, 0 = none, 1 = right
var lean_amount := 0.0
var target_lean := 0.0

const LEAN_ANGLE = 15.0
const LEAN_OFFSET = 0.3
const LEAN_SPEED = 10.0

func _input(event):
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

func _process(delta):
	var sprinting = Input.is_action_pressed("sprint")

	if sprinting:
		lean_state = 0  # cancel lean

	target_lean = lean_state
	lean_amount = lerp(lean_amount, target_lean, LEAN_SPEED * delta)
	apply_lean()

func apply_lean():
	rotation_degrees.z = lean_amount * LEAN_ANGLE
	position.x = lean_amount * LEAN_OFFSET
