# WORK IN PROGRESS
# Code for the trait system

extends Node

var config: ConfigFile
var is_connected_to_db: bool
var traits: Dictionary

const ENVIRONMENT_VARIABLES = "environment" 

func _ready():
	is_connected_to_db = false
	config = load_env_file() 
	await login()
	await load_traits()
	print(traits)

func load_env_file() -> ConfigFile:
	var config = ConfigFile.new()
	var error = config.load("res://.env")
	if error != OK:
		print("Could not load env file")
		return null
	return config

func login():
	var email = config.get_value(ENVIRONMENT_VARIABLES, "EMAIL")
	var password = config.get_value(ENVIRONMENT_VARIABLES, "PASSWORD")
	var sign_result: AuthTask = await Supabase.auth.sign_in(email, password).completed
	if sign_result.user == null:
		print("Failed to sign in")
		is_connected_to_db = false
	else: 
		is_connected_to_db = true
		
		
func load_traits()->Dictionary:
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
