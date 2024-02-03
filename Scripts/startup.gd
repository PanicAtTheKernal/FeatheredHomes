extends Node

const welcome_text: String = """Welcome to the Feathered Home Pre-Alpha. Please note that the app is still under development, and you might find issues. The goal with this Alpha is to test the camera, and the UI functions. The bird generator is partially disabled in this build, but any bird you find will appear in the bird history tab (Top left button). Player data is reset everytime the app is loaded. This will change in the next build. You can send feedback to Daniel directly or open an issue on the GitHub Repo. Thank you for checking out the app, and have fun playing around with it."""

# Rotate the screen to potrait on moblie devices
func _ready()->void:
	_setup_screen_orientation()
	_print_welcome_screen()
	

func _print_welcome_screen():
	var node: Array[Node] = get_tree().get_nodes_in_group("Dialog")
	if len(node) > 0:
		await node[-1].ready
		get_tree().call_group("Dialog", "display", welcome_text, "Welcome!")
	

func _setup_screen_orientation():
	var os_name = OS.get_name()
	match os_name:
		"Android", "iOS":
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
