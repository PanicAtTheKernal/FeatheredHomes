extends Node

const NON_MOBLIE_SIZE = 1080
const welcome_text: String = """Welcome to the Feathered Home Pre-Alpha. Please note that the app is still under development, and you might find issues. The goal with this Alpha is to test the camera, bird asset generator, UI functions and bird AI behaviour. Player data is reset every time the app is loaded. You can get new birds by photographing one or clicking on the magnify button to open a text search. This app collects anonymised data from users for debugging purposes. Any images you upload are not stored. No identifiable information is collected. By pressing ok, you agree to these terms. You can send feedback to Daniel directly or open an issue on the GitHub Repo. Thank you for checking out the app, and have fun playing around with it."""
const BIRD_SFX_FILE_PATH = "res://Assets/Sounds/SFX/Bird_SFX/"

var graph
var standard_notification: AudioStreamMP3
var grand_notification: AudioStreamMP3
var camera_notification: AudioStreamWAV
var bird_sounds: Dictionary
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "Startup"
}
# Rotate the screen to potrait on moblie devices
func _ready()->void:
	_get_sounds()
	_load_bird_sounds()
	_setup_screen_orientation()
	_print_welcome_screen()
	get_tree().set_auto_accept_quit(false)

	

func _print_welcome_screen()->void:
	var node: Array[Node] = get_tree().get_nodes_in_group("Dialog")
	if len(node) > 0:
		# Wait for all nodes to be ready
		await node[-1].ready
		get_tree().call_group("Dialog", "display", welcome_text, "Welcome!", true, false)
		get_tree().call_group("PlayerCamera", "turn_off_movement")
		get_tree().call_group("Dialog", "increase_dialog")
	# ;)
	get_tree().root.find_child("EasterEgg", true, false).show()

func _setup_screen_orientation()->void:
	var os_name = OS.get_name()
	match os_name:
		"Android", "iOS":
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
 
func _get_sounds()->void:
	standard_notification = preload("res://Assets/Sounds/SFX/Feathered Homes NOTIFICATION (A).mp3")
	grand_notification = preload("res://Assets/Sounds/SFX/Feathered Homes NOTIFICATION (B).mp3")
	camera_notification = preload("res://Assets/Sounds/SFX/Camera Notification.wav")

func _load_bird_sounds()->void:
	var sound_folder = DirAccess.open(BIRD_SFX_FILE_PATH)
	if sound_folder:
		sound_folder.list_dir_begin()
		var file_name = sound_folder.get_next()
		while file_name != "":
			if not sound_folder.current_is_dir() and file_name.ends_with(".mp3.import"):
				var bird_sfx_file = file_name.replace("."+file_name.get_extension(), "")
				var bird_sfx_name = bird_sfx_file.replace(".mp3", "")
				var bird_sfx_path = BIRD_SFX_FILE_PATH+bird_sfx_file
				bird_sounds[bird_sfx_name] = load(bird_sfx_path)
				Logger.print_debug("Loaded bird sound effect: " + bird_sfx_file, logger_key)
			file_name = sound_folder.get_next()
	else:
		print("An error occurred when trying to access the path.")
