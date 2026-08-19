extends HSlider

func _ready() -> void:
	get_viewport().scaling_3d_scale = 1.0

func value_changed(value: float):
	get_viewport().scaling_3d_scale = value
