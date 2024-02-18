extends Node

const ENVIRONMENT_VARIABLES = "environment" 
const DIET_TABLE = "Diet"
const SHAPE_TABLE = "BirdShape"
const FAMILY_TO_SHAPE_TABLE = "FamilyToShape"

var config: ConfigFile
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
	var config = ConfigFile.new()
	var error = config.load("res://.env")
	if error != OK:
		Logger.print_debug("Could not load env file", logger_key)
		return null
	return config

func _login()->void:
	var email = config.get_value(ENVIRONMENT_VARIABLES, "EMAIL")
	var password = config.get_value(ENVIRONMENT_VARIABLES, "PASSWORD")
	var sign_result: AuthTask = await Supabase.auth.sign_in(email, password).completed
	if sign_result.user == null:
		Logger.print_debug("Failed to sign in", logger_key)
		is_connected_to_db = false
	else: 
		is_connected_to_db = true

func get_anon_token()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "ANON_TOKEN", "")

func get_image_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "IMAGE_ENDPOINT", "")

func get_fetch_species_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "FIND_SPECIES_ENDPOINT", "")

func get_search_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "SEARCH_ENDPOINT", "")

func fetch_diet_name(diet_id: String)->String:
	var diet_query: SupabaseQuery = SupabaseQuery.new().from(DIET_TABLE).select(["DietName"]).eq("DietId", diet_id)
	var diet_result = await Supabase.database.query(diet_query).completed
	return diet_result.data[0]["DietName"]

func fetch_shape(shape_id: String)->Dictionary:
	var shape_query: SupabaseQuery = SupabaseQuery.new().from(SHAPE_TABLE).select().eq("BirdShapeId", shape_id)
	var shape_result = await Supabase.database.query(shape_query).completed
	return shape_result.data[0] as Dictionary

func fetch_supported_familes()->Array[String]:
	var family_query: SupabaseQuery = SupabaseQuery.new().from(FAMILY_TO_SHAPE_TABLE).select()
	var family_result = await Supabase.database.query(family_query).completed
	var supported_familes: Array[String] = []
	for family in family_result.data:
		supported_familes.push_back(family["Family"])
	return supported_familes

func download_image(image_name, file_name)->void:
	var storageResult: StorageTask = await Supabase.storage.from("BirdAssets").download(image_name, BirdResourceManager.BIRD_DATA_PATH + file_name).completed
	if storageResult.error != null:
		Logger.print_debug(storageResult.error, logger_key)
