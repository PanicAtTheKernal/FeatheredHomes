extends Node


# Rotate the screen to potrait on moblie devices
func _ready():
	var os_name = OS.get_name()
	match os_name:
		"Android", "iOS":
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
