extends Label

var time_passed: float = 0.0

func _process(delta: float) -> void:
	if global.fps_counter == true:
		time_passed += delta
		# Update the text roughly once every 1 second
		if time_passed >= 1.0:
			text = "fps: " + str(Engine.get_frames_per_second())
			time_passed = 0.0 # Reset the tracker
