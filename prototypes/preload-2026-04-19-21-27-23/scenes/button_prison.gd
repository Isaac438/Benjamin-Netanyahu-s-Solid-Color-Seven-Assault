extends Button

@export var map_index := 3

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	global.set_map(map_index)
