extends Node

const BIRD_DATA_PATH: String = "user://Birds/"
const BIRD_FILE_EXTENSION: String = ".tres"

signal new_bird

var birds: Array[BirdInfo]
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdResourceManager"
}


# Called when the node enters the scene tree for the first time.
func _ready()->void:
	_initalise_bird_data()
	_create_birds_folder()
	# TODO TEMP
	var temp_bird: BirdInfo = ResourceLoader.load("res://Assets/Birds/NewBird/sample_bird_info.tres")
	birds.push_back(temp_bird)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta)->void:
	pass

func _initalise_bird_data()->void:
	Logger.print_debug("Setting up bird data", logger_key)
	birds = PlayerResourceManager.player_data.birds

func _create_birds_folder()->void:
	if !DirAccess.dir_exists_absolute(BIRD_DATA_PATH):
		Logger.print_debug("Creating Birds folder", logger_key)
		DirAccess.make_dir_recursive_absolute(BIRD_DATA_PATH)

func _has_bird_been_imported(bird_species: String)->bool:
	return false

func _load_local_bird(bird_species)->BirdSpecies:
	return BirdSpecies.new()

func add_bird(bird_species: String)->void:
	var new_entry = BirdInfo.new()
	if _has_bird_been_imported(bird_species):
		new_entry.species = _load_local_bird(bird_species)
	else:
		var importer = BirdAssetImporter.new(bird_species)
		add_child(importer)
		Logger.print_debug("Starting import", logger_key)
		importer.import()
		# Wait for the bird to be imported
		await importer.bird_imported
		new_entry.species = importer.get_bird()
		importer.queue_free()
	Logger.print_debug("Added new bird", logger_key)
	birds.push_back(new_entry)
	new_bird.emit(new_entry)

func get_bird_list_items()->PackedStringArray:
	var bird_list_items: PackedStringArray 
	for bird in birds:
		bird_list_items.push_back(bird.species.name)
	return bird_list_items

func get_bird(index: int)->BirdInfo:
	return birds[index]
