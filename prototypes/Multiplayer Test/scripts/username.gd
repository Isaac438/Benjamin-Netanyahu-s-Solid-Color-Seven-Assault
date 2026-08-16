extends Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = Local.username

var ticks = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ticks += delta
	if ticks >= 2.0:
		ticks = 0.0
		if text != Local.username:
			text = Local.username
