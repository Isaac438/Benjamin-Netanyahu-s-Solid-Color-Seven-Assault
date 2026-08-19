extends HSlider

func _ready() -> void:
	get_viewport().scaling_3d_scale = 1.0

var ticks: float = 0.0
func _process(delta: float) -> void:
	ticks+=delta
	if ticks >= 1.0:
		value_changed(value)

func value_changed(value: float):
	if value == 1.0:
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
		get_viewport().scaling_3d_scale = 1.0
	else:
		get_viewport().scaling_3d_scale = value
