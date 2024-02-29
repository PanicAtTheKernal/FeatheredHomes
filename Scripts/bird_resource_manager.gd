extends Node

const BIRD_DATA_PATH: String = "user://Birds/"
const BIRD_FILE_EXTENSION: String = "-INFO.tres"

var birds: Array[BirdInfo]
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdResourceManager"
}

signal new_bird_added

func _ready()->void:
	_initalise_bird_data()
	_create_birds_folder()
	_remove_outdated_bird_data()

func _initalise_bird_data()->void:
	Logger.print_debug("Setting up bird data", logger_key)
	birds = PlayerResourceManager.player_data.birds

func _create_birds_folder()->void:
	if !DirAccess.dir_exists_absolute(BIRD_DATA_PATH):
		Logger.print_debug("Creating Birds folder", logger_key)
		DirAccess.make_dir_recursive_absolute(BIRD_DATA_PATH)

func _remove_outdated_bird_data()->void:
	var files = DirAccess.get_files_at(BIRD_DATA_PATH)
	var file_regex = RegEx.new()
	file_regex.compile(str("[A-Z-]*[-]*?[A-Z]*?-INFO[.]tres"))
	var image_regex = RegEx.new()
	image_regex.compile(str("(:?[A-Z-]*)[-]*?[A-Z]*?-INFO[.]tres"))
	for file in files:
		# Make sure to load the bird resource files
		if !file_regex.search(file):
			continue
		var bird = ResourceLoader.load(BIRD_DATA_PATH+file)
		if bird == null or bird.version < Database.get_version():
			Logger.print_debug("Removing outdated file "+file, logger_key)
			var image_file = file.replace("-INFO.tres", ".png").to_lower()
			Logger.print_debug("Removing outdated image File "+image_file, logger_key)
			DirAccess.remove_absolute(BIRD_DATA_PATH+file)
			DirAccess.remove_absolute(BIRD_DATA_PATH+image_file)

func _find_bird_files(bird_species: String)->Array[String]:
	var bird_file_name = bird_species.replace(" ", "-").to_upper()
	var files = DirAccess.get_files_at(BIRD_DATA_PATH)
	var file_regex = RegEx.new()
	var resource_file: Array[String] = []
	file_regex.compile(str(bird_file_name,"[-]*?[A-Z]*?-INFO[.]tres"))
	Logger.print_debug(files, logger_key)
	for file in files:
		if file_regex.search(file):
			Logger.print_debug(str("Found file ",file), logger_key)
			resource_file.push_back(file)
	return resource_file

func _import_bird(bird_data: Dictionary, gender: String)->BirdInfo:
	var importer = BirdAssetImporter.new(bird_data, gender)
	add_child(importer)
	var new_bird = await importer.import()
	importer.queue_free()
	return new_bird

func find_bird(bird_name: String)->void:
	var search_request = FetchBirdRequest.new()
	add_child(search_request)
	var search_response = await  search_request.fetch_bird_species(bird_name, Database.get_search_endpoint())
	search_request.queue_free()
	if search_response["isValid"]:
		add_bird(search_response["speciesName"])
	else:
		get_tree().call_group("Dialog", "display", "Could not find bird")
		get_tree().call_group("LoadingSearchButton", "hide_loading")

func save_bird(bird_data: BirdInfo)->void:
	var bird_name = bird_data.species.name.replace(" ", "-")
	var file_name = (bird_name+"-"+bird_data.gender).to_upper()+BIRD_FILE_EXTENSION
	Logger.print_debug("Saving player data", logger_key)	
	var error = ResourceSaver.save(bird_data, BIRD_DATA_PATH+file_name)
	if error != OK:
		Logger.print_debug(str("Error saving player data",error), logger_key)

func add_bird(bird_species: String)->void:
	var bird_files: Array[String] = _find_bird_files(bird_species)
	var bird: BirdInfo
	if not bird_files.is_empty():
		var bird_file = bird_files.pick_random()
		bird = ResourceLoader.load(BIRD_DATA_PATH+bird_file)
		Logger.print_debug("Loaded local copy", logger_key)
	else:
		var bird_request: FetchBirdRequest = FetchBirdRequest.new()#
		add_child(bird_request)
		var bird_data: Dictionary = await bird_request.fetch_bird_species(bird_species, Database.get_fetch_species_endpoint())
		# If it's empty then the request return an error
		if bird_data.is_empty():
			get_tree().call_group("LoadingButton", "hide_loading")
			get_tree().call_group("LoadingSearchButton", "hide_loading")
			return
		bird_request.queue_free()
		if bird_data["birdUnisex"]:
			bird = await  _import_bird(bird_data, "Unisex")
			# Give the bird a random gender if the bird apperance is unisex
			bird.gender = ["male","female"].pick_random()
		else:
			Logger.print_debug("Starting import", logger_key)
			var bird_infos: Array[BirdInfo] = []
			var male_bird = await _import_bird(bird_data, "male")
			var female_bird = await _import_bird(bird_data, "female")
			save_bird(male_bird)
			save_bird(female_bird)
			bird_infos.push_back(male_bird)
			bird_infos.push_back(female_bird)
			bird = bird_infos.pick_random()
	get_tree().call_group("BirdManager", "create_bird", bird)
	birds.push_back(bird)
	Logger.print_debug("Added new bird", logger_key)
	get_tree().call_group("LoadingButton", "hide_loading")
	get_tree().call_group("LoadingSearchButton", "hide_loading")
	new_bird_added.emit()

func get_bird_list_items()->PackedStringArray:
	var bird_list_items: PackedStringArray = []
	for bird in birds:
		bird_list_items.push_back(bird.species.name)
	return bird_list_items

func get_bird(index: int)->BirdInfo:
	return birds[index]
