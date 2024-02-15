extends Node

const ENVIRONMENT_VARIABLES = "environment" 

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
	#await _load_traits()
	#Logger.print_debug(traits, logger_key)

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

func _load_traits()->Dictionary:
	if traits.size() > 0:
		return traits
	var traits_query: SupabaseQuery = SupabaseQuery.new().from("Traits").select()
	var traits_result = await Supabase.database.query(traits_query).completed
	for row in traits_result.data:
		var trait_name = row["traitName"]
		var trait_rule = row["traitRule"]
		var trait_pattern = row["traitPattern"]
		var trait_entry = {
			"trait_rule": trait_rule,
			"trait_pattern": trait_pattern
		}
		traits[trait_name] = trait_entry
	return traits

func get_anon_token()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "ANON_TOKEN", "")

func get_image_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "IMAGE_ENDPOINT", "")

func get_fetch_species_endpoint()->String:
	return config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "FIND_SPECIES_URL", "")

func fetch_bird_species()->Dictionary:
	var http_request = HTTPRequest.new()
	var result = await http_request.request_completed
	result.body
	add_child(http_request)
	return {}
