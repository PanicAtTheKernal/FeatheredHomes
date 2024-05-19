extends Node


const ENVIRONMENT_VARIABLES = "environment" 
const TABLES = {
	DIET = "DIET",
	SHAPE = "SHAPE",
	FAMILY_TO_SHAPE = "FAMILY_TO_SHAPE",
	SOUND = "SOUND",
	NEST = "NEST",
	BIRD = "BIRD_SPECIES"
}
const DATABASE_NAME = {
	DIET = "Diet",
	SHAPE = "BirdShape",
	FAMILY_TO_SHAPE = "FamilyToShape",
	SOUND = "Sound",
	NEST = "Nest",
	BIRD = "BirdSpecies"
}
const ID_COLS = {
	DIET = "DietId",
	SHAPE = "BirdShapeId",
	FAMILY_TO_SHAPE = "Family",
	SOUND = "Id",
	NEST = "Id",
	BIRD = "BirdId"
}

var config: ConfigFile
var access_token: String
var is_connected_to_db: bool
var traits: Dictionary
var logger_key = {
	"type": Logger.LogType.DATABASE,
	"obj": ""
}

func _ready()->void:
	is_connected_to_db = false
	config = _load_env_file() 
	await _login()
	if not is_connected_to_db:
		return

func _load_env_file()->ConfigFile:
	var config_local = ConfigFile.new()
	var error = config_local.load("res://.env")
	if error != OK:
		Logger.print_debug("Could not load env file", logger_key)
		return null
	return config_local

func _login()->void:
	var email = config.get_value(ENVIRONMENT_VARIABLES, "EMAIL")
	var password = config.get_value(ENVIRONMENT_VARIABLES, "PASSWORD")
	var sign_result: AuthTask = await Supabase.auth.sign_in(email, password).completed
	if sign_result.user == null:
		Logger.print_debug("Failed to sign in", logger_key)
		is_connected_to_db = false
	else: 
		access_token = sign_result.user.access_token
		is_connected_to_db = true

func get_refresh_token()->String:
	return access_token

func get_image_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "IMAGE_ENDPOINT", "")

func get_fetch_species_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "FIND_SPECIES_ENDPOINT", "")

func get_search_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "SEARCH_ENDPOINT", "")

func get_version()->float:
	return float(config.get_value(ENVIRONMENT_VARIABLES, "VERSION", "0.1"))

func fetch_row(table_name: String, id: String)->Dictionary:
	var query: SupabaseQuery = SupabaseQuery.new().from(DATABASE_NAME[table_name]).select().eq(ID_COLS[table_name], id)
	var result = await Supabase.database.query(query).completed
	return result.data[0] as Dictionary

func fetch_value(table_name: String, id: String, col_name: String)->String:
	var result = await fetch_row(table_name, id)
	return result[col_name]

func fetch_supported_familes()->Array[String]:
	var family_query: SupabaseQuery = SupabaseQuery.new().from(DATABASE_NAME.FAMILY_TO_SHAPE).select()
	var family_result = await Supabase.database.query(family_query).completed
	var supported_familes: Array[String] = []
	for family in family_result.data:
		supported_familes.push_back(family["Family"])
	return supported_familes

func fetch_all_birds()->Array[String]:
	var species_query: SupabaseQuery = SupabaseQuery.new().from("BirdSpecies").select()
	var species_result = await Supabase.database.query(species_query).completed
	var supported_familes: Array[String] = []
	for family in species_result.data:
		supported_familes.push_back(family["birdName"])
	return supported_familes

func download_image(image_name, file_name)->void:
	var storageResult: StorageTask = await Supabase.storage.from("BirdAssets").download(image_name, BirdResourceManager.BIRD_DATA_PATH + file_name).completed
	if storageResult.error != null:
		Logger.print_debug(storageResult.error, logger_key)
