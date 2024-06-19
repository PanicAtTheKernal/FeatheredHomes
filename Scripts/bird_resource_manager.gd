extends Node

const BIRD_DATA_PATH: String = "user://Birds/"
const BIRD_FILE_EXTENSION: String = "-INFO.tres"
const LOCAL_BIRDS: String = "res://Assets/Birds/LocalBirds/"

var birds: Array[BirdInfo]
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdResourceManager"
}
var bird_manager: BirdManager
var collected_birds: CollectedBirds = CollectedBirds.new()
var birds_names: Array[String]

signal new_bird_added

func _ready()->void:
	_initalise_bird_data()
	_create_birds_folder()
	_remove_outdated_bird_data()
	_get_bird_manager()
	#_load_birds_from_save()
	_load_birds()

func _get_bird_manager()->void:
	bird_manager = get_tree().root.find_child("Birds", true, false)

func _initalise_bird_data()->void:
	Logger.print_debug("Setting up bird data", logger_key)
	birds_names = await Database.fetch_all_birds()

func _create_birds_folder()->void:
	if !DirAccess.dir_exists_absolute(BIRD_DATA_PATH):
		Logger.print_debug("Creating Birds folder", logger_key)
		DirAccess.make_dir_recursive_absolute(BIRD_DATA_PATH)

func _load_birds()-> void:
	var files = DirAccess.get_files_at(LOCAL_BIRDS)
	for file in files:
		var bird = ResourceLoader.load(LOCAL_BIRDS+file)
		if bird == null:
			continue
		birds.push_back(bird)

func _load_birds_from_save() -> void:
	if len(PlayerResourceManager.player_data.birds) < 1:
		return
	for bird_state: BirdState in PlayerResourceManager.player_data.birds:
		var bird_info = load_bird(bird_state.species_name, bird_state.gender)
		# Skip if the bird data gets removed
		if bird_info == null:
			continue
		bird_manager.load_bird(bird_info, bird_state)
	PlayerResourceManager.player_data.birds = []

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
	if search_response.has("isValid"):
		add_bird(search_response["speciesName"])
	else:
		var dialog = Dialog.new().message("Could not find bird").regular_notification()
		GlobalDialog.create(dialog)
		get_tree().call_group("LoadingSearchButton", "hide_loading")

func save_bird(bird_data: BirdInfo)->void:
	var bird_name = bird_data.species.name.replace(" ", "-")
	var file_name = (bird_name+"-"+bird_data.gender).to_upper()+BIRD_FILE_EXTENSION
	Logger.print_debug("Saving player data", logger_key)	
	var error = ResourceSaver.save(bird_data, BIRD_DATA_PATH+file_name)
	if error != OK:
		Logger.print_debug(str("Error saving player data",error), logger_key)

func load_bird(bird_species: String, gender: String = "")->BirdInfo:
	var search_bird = bird_species if gender == "" else bird_species + " " + gender 
	var bird_files: Array[String] = _find_bird_files(search_bird)
	var bird: BirdInfo
	if not bird_files.is_empty():
		var bird_file = bird_files.pick_random()
		bird = ResourceLoader.load(BIRD_DATA_PATH+bird_file)
		Logger.print_debug("Loaded local copy", logger_key)
	return bird

func add_bird(bird_species_name: String, random_bird: bool=false)->void:
	var bird_species = bird_species_name
	if random_bird:
		randomize()
		bird_species = birds_names.pick_random()
	var bird: BirdInfo = load_bird(bird_species)
	if bird == null:
		var bird_request: FetchBirdRequest = FetchBirdRequest.new()#
		add_child(bird_request)
		var bird_data: Dictionary = await bird_request.fetch_bird_species(bird_species, Database.get_fetch_species_endpoint())
		# If it's empty then the request return an error
		if bird_data.is_empty():
			get_tree().call_group("LoadingButton", "hide_loading")
			get_tree().call_group("LoadingSearchButton", "hide_loading")
			return
		bird_request.queue_free()
		if bird_data.has("birdUnisex"):
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
	var new_bird = bird_manager.create_bird(bird)
	bird_manager.add_bird(new_bird, random_bird)
	collected_birds.add(bird)
	Logger.print_debug("Added new bird", logger_key)
	get_tree().call_group("LoadingButton", "hide_loading")
	get_tree().call_group("LoadingSearchButton", "hide_loading")
	#new_bird_added.emit()

