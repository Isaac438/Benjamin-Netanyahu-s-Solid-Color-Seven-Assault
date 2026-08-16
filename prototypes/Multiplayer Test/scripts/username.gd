extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = global.username

var ticks = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ticks += delta
	if ticks >= 20.0:
		ticks = 0.0
		if text != global.username:
			text = global.username
