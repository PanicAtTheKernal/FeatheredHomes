extends Node

const LOG_DATA_PATH: String = "user://Logs/"
const LOG_FILE_EXTENSION: String = ".md"

enum LogType {
	RESOURCE,
	CAMERA,
	DATABASE,
	NAVIGATION,
	AI,
	GENERAL,
	UI,
	BUILDER,
	ANIMATION
}

var is_debug: bool = true :
	set(value): value
	get: return is_debug
var seperate_bird_logs: bool = false :
	set(value): value
	get: return seperate_bird_logs
var allowed_logs: Dictionary = {
	LogType.RESOURCE: true,
	LogType.CAMERA: true,
	LogType.DATABASE: true,
	LogType.NAVIGATION: true,
	LogType.AI: true,
	LogType.GENERAL: true,
	LogType.UI: true,
	LogType.BUILDER: true,
	LogType.ANIMATION: true
}

var log_colours: Dictionary = {
	LogType.RESOURCE: "[color=green][b]Resource (<>): [/b][/color]",
	LogType.CAMERA: "[color=orange][b]Camera (<>): [/b][/color]",
	LogType.DATABASE: "[color=red][b]Database (<>): [/b][/color]",
	LogType.NAVIGATION: "[color=cyan][b]Navigation (<>): [/b][/color]",
	LogType.AI: "[color=yellow][b]AI (<>): [/b][/color]",
	LogType.GENERAL: "[color=white][b]General (<>): [/b][/color]",
	LogType.UI: "[color=purple][b]UI (<>): [/b][/color]",
	LogType.BUILDER: "[color=blue][b]Builder (<>): [/b][/color]",
	LogType.ANIMATION: "[color=pink][b]Animation (<>): [/b][/color]"
}
var log_file
var bird_log_files: Dictionary = {}

func _ready() -> void:
	_create_new_log()
	_clear_bird_logs()

func _is_log_allowed(type:LogType)->bool:
	return allowed_logs.get(type)

func _create_new_log() ->void:
	log_file = FileAccess.open("user://log.md", FileAccess.WRITE)	

# Clear out the out log for new ones
func _clear_bird_logs()-> void:
	if DirAccess.dir_exists_absolute(LOG_DATA_PATH):
		var dir = DirAccess.open(LOG_DATA_PATH)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					dir.remove(file_name)
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
		dir.remove(".")
	DirAccess.make_dir_absolute(LOG_DATA_PATH)

func _get_bird_log(obj_name: String)->FileAccess:
	if not seperate_bird_logs:
		return null
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(obj_name)
	if result:
		var id = int(result.get_string())
		return bird_log_files[id]
	return null

func create_new_bird_log(id: int)->void:
	if not is_debug or not seperate_bird_logs:
		return
	var file_name: String = LOG_DATA_PATH + "bird_" + str(id) + LOG_FILE_EXTENSION
	bird_log_files[id] = FileAccess.open(file_name, FileAccess.WRITE)

func print_debug(message: Variant, key: Dictionary)->void:
	# Failsafe incase I forget to disable the logger
	var os_name = OS.get_name()
	var type = key.get("type")
	var object_name = key.get("obj")
	if not is_debug or not _is_log_allowed(type) :
		return
	var get_log_colour: String = log_colours.get(type)
	var replace_obj_name: String = "<>" if object_name != "" else " (<>)" 
	get_log_colour = get_log_colour.replace(replace_obj_name, object_name)
	if (os_name == "Linux" or os_name == "Windows"):
		_print_to_log(object_name, get_log_colour, message)
	print_rich(get_log_colour,message)

func _print_to_log(object_name, get_log_colour, message)->void:
	var bird_log = _get_bird_log(object_name)
	if bird_log != null:
		bird_log.store_string(str(get_log_colour,message,"\n"))
		return
	log_file.store_string(str(get_log_colour,message,"\n"))

func print_success(message: Variant, key: Dictionary)->void:
	self.print_debug(str("[color=green]",message,"[/color]"),key)
	
func print_fail(message: Variant, key: Dictionary)->void:
	self.print_debug(str("[color=red]",message,"[/color]"),key)

func print_running(message: Variant, key: Dictionary)->void:
	self.print_debug(str("[color=cyan]",message,"[/color]"),key)
