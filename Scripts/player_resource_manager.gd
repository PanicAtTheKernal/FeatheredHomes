extends Node

const PLAYER_DATA_PATH: String = "user://PlayerData/"
const PLAYER_BIRDS_PATH: String = PLAYER_DATA_PATH + "Birds/"
const PLAYER_DATA_FILE: String = "player-data.tres"

var player_data: PlayerData
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "PlayerResourceManager"
}


# Called when the node enters the scene tree for the first time.
func _ready()->void:
	_create_player_data_folder()
	_load_player_data()
	# TODO Temp for testing while the player data structure is still WIP
	_initalise_player_data()
	

func _create_player_data_folder()->void:
	if !DirAccess.dir_exists_absolute(PLAYER_DATA_PATH):
		Logger.print_debug("Creating PlayerData folder", logger_key)
		DirAccess.make_dir_recursive_absolute(PLAYER_DATA_PATH)

func _initalise_player_data()->void:
	if not ResourceLoader.exists(PLAYER_DATA_PATH+PLAYER_DATA_FILE):
		_create_player_data()

func _create_player_data()->void:
	Logger.print_debug("Initalising player data", logger_key)
	player_data = PlayerData.new()
	player_data.music_volume = 0.5
	player_data.sound_volume = 0.5
	ResourceSaver.save(player_data, PLAYER_DATA_PATH+PLAYER_DATA_FILE)

func _load_player_data()->void:
	if ResourceLoader.exists(PLAYER_DATA_PATH+PLAYER_DATA_FILE):
		Logger.print_debug("Loading player data", logger_key)
		player_data = ResourceLoader.load(PLAYER_DATA_PATH+PLAYER_DATA_FILE)

func save_player_data()->void:
	Logger.print_debug("Saving player data", logger_key)	
	var error = ResourceSaver.save(player_data, PLAYER_DATA_PATH+PLAYER_DATA_FILE)
	if error != OK:
		Logger.print_debug(str("Error saving player data",error), logger_key)
