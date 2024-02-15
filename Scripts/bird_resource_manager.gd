extends Node

const BIRD_DATA_PATH: String = "user://Birds/"
const BIRD_FILE_EXTENSION: String = ".tres"

signal new_bird

var bird_manager: BirdManager
var birds: Array[BirdInfo]
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdResourceManager"
}

func _ready()->void:
	_initalise_bird_data()
	_create_birds_folder()
	# TODO TEMP
	var temp_bird: BirdInfo = ResourceLoader.load("res://Assets/Birds/NewBird/sample_bird_info.tres")
	birds.push_back(temp_bird)

func _initalise_bird_data()->void:
	Logger.print_debug("Setting up bird data", logger_key)
	birds = PlayerResourceManager.player_data.birds

func _create_birds_folder()->void:
	if !DirAccess.dir_exists_absolute(BIRD_DATA_PATH):
		Logger.print_debug("Creating Birds folder", logger_key)
		DirAccess.make_dir_recursive_absolute(BIRD_DATA_PATH)

func _find_bird_file(bird_species: String)->String:
	var bird_file_name = bird_species.replace(" ", "-")
	var files = DirAccess.get_files_at(BIRD_DATA_PATH)
	var file_regex = RegEx.new()
	file_regex.compile("[^*]*"+bird_file_name+"-info"+"[^*]*[.]tres")
	Logger.print_debug(files, logger_key)
	for file in files:
		if file_regex.search(file):
			Logger.print_debug(str("Found file ",file), logger_key)
			return file
	return ""

func add_bird(bird_species: String)->void:
	var bird_file = _find_bird_file(bird_species)
	if bird_file != "":
		var bird: BirdInfo = ResourceLoader.load(BIRD_DATA_PATH+bird_file)
		Logger.print_debug("Loaded local copy", logger_key)
		bird_manager.create_bird(bird)
		birds.push_back(bird)
	else:
		var importer = BirdAssetImporter.new(bird_species)
		add_child(importer)
		Logger.print_debug("Starting import", logger_key)
		importer.import()
		await importer.bird_imported
		var bird = importer.get_bird()
		bird_manager.create_bird(bird)
		birds.push_back(bird)
		importer.queue_free()
	Logger.print_debug("Added new bird", logger_key)

func get_bird_list_items()->PackedStringArray:
	var bird_list_items: PackedStringArray = []
	for bird in birds:
		bird_list_items.push_back(bird.species.name)
	return bird_list_items

func get_bird(index: int)->BirdInfo:
	return birds[index]
