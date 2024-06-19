extends Node

const NON_MOBLIE_SIZE = 1080
const welcome_text: String = "Welcome to Feathered Homes, where you can bring bird photos to life with the power of generative AI! This web version is a special offline build. Generative AI features are only available on the Android build. This build allows for the spawning of a handful of birds."
const BIRD_SFX_FILE_PATH = "res://Assets/Sounds/SFX/Bird_SFX/"

var graph
var standard_notification: AudioStreamMP3 = ResourceFiles.standard_notification
var grand_notification: AudioStreamMP3 = ResourceFiles.grand_notification
var camera_notification: AudioStreamWAV = ResourceFiles.camera_notification
var bird_sounds: Dictionary
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "Startup"
}
# Rotate the screen to potrait on moblie devices
func _ready()->void:
	_load_bird_sounds()
	_setup_screen_orientation()
	_load_easter_egg()
	call_deferred("_print_welcome_screen")
	

func _print_welcome_screen()->void:
	var welcome_dialog = Dialog.new().message(welcome_text).header("Welcome!").fit_content(false).grand_notification().minimum_height(800)
	GlobalDialog.create(welcome_dialog)
	get_tree().call_group("PlayerCamera", "turn_off_movement")

func _load_easter_egg()->void:
	var easter_egg = get_tree().root.find_child("EasterEgg", true, false)
	if easter_egg != null:
		easter_egg.show()

func _setup_screen_orientation()->void:
	var os_name = OS.get_name()
	match os_name:
		"Android", "iOS":
			DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

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
