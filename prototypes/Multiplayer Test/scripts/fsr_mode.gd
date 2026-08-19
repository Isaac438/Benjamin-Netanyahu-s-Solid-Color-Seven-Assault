extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_fsr_mode_changed(value: float):
	if value <= 30.0:
		text = "Bilinear"
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		get_viewport().scaling_3d_scale = 1.0
		print("Using Bilinear upscaling")
	elif value >= 80.0:
		text = "FSR 2 On"
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR2
		print("using FSR 2.2")
	else:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		text = "FSR 1 On"
		print("Using FSR 1.0")
