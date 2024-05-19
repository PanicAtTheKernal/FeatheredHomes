extends Node

const NON_MOBLIE_SIZE = 1080
const welcome_text: String = "Welcome to Feathered Homes, where you can bring bird photos to life with the power of generative AI! Point your camera, snap a picture, and within a minute or two, connect with the beauty of nature in a whole new way. If you have any issues or feedback, mention it on the survey or open a ticket on the GitHub page at https://github.com/PanicAtTheKernal/FinalYearProject. This app collects anonymised data from users for debugging purposes. Any images you upload are not stored. No identifiable information is collected. By pressing ok, you agree to these terms."
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
	_load_easter_egg()
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

func _load_easter_egg()->void:
	var easter_egg = get_tree().root.find_child("EasterEgg", true, false)
	if easter_egg != null:
		easter_egg.show()

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
