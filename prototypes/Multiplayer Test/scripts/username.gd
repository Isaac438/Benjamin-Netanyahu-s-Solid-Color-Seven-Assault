extends Label3D

@onready var net = get_node("/root/Main/NetworkManager")

func _ready() -> void:
	update_username()

func update_username() -> void:
	var player_id := get_parent().name.to_int()

	text = net.players.get(player_id, "Player")
