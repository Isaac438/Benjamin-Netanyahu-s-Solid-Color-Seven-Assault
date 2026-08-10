extends Button

@export var map_index := 2
@onready var map_root: Node3D = get_node("/root/Main/World/MapRoot")

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	global.set_map(map_index)
	map_root.request_map_change(map_index)
