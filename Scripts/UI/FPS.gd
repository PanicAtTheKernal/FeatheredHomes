extends Label

# Shows the current frames per second
func _process(_delta):
	text = str(Engine.get_frames_per_second())
