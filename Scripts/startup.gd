extends Node

const NON_MOBLIE_SIZE = 1080

const welcome_text: String = """Welcome to the Feathered Home Pre-Alpha. Please note that the app is still under development, and you might find issues. The goal with this Alpha is to test the camera, bird asset generator, UI functions and bird AI behaviour. Player data is reset every time the app is loaded. You can get new birds by photographing one or clicking on the magnify button to open a text search. This app collects anonymised data from users for debugging purposes. Any images you upload are not stored. No identifiable information is collected. By pressing ok, you agree to these terms. You can send feedback to Daniel directly or open an issue on the GitHub Repo. Thank you for checking out the app, and have fun playing around with it."""
var graph
# Rotate the screen to potrait on moblie devices
func _ready()->void:
	_setup_screen_orientation()
	_print_welcome_screen()
	graph = DebugDraw2D.create_fps_graph("FPS")

func _print_welcome_screen()->void:
	var node: Array[Node] = get_tree().get_nodes_in_group("Dialog")
	if len(node) > 0:
		await node[-1].ready
		get_tree().call_group("Dialog", "display", welcome_text, "Welcome!", false)
		get_tree().call_group("PlayerCamera", "turn_off_movement")
		get_tree().call_group("Dialog", "increase_dialog")		
	

func _setup_screen_orientation()->void:
	var os_name = OS.get_name()
	match os_name:
		"Android", "iOS":
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
 
