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
	if not is_connected_to_db:
		return
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
		print("Database: Failed to sign in")
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

func prep_image_request(image: Image):
	# Convert the image into base64 to send over http
	var base64_image = Marshalls.raw_to_base64(image.get_data())
	var request_data = {
		"data": base64_image
	}
	return JSON.stringify(request_data)

func send_image_request(image: Image):
	var data = prep_image_request(image)
	var auth_header = "Authorization: Bearer " + config.get_value(ENVIRONMENT_VARIABLES, "ANON_TOKEN", "")
	var content_type_header = "Content-Type: application/json"
	var headers = [auth_header, content_type_header]
	var url = config.get_value(ENVIRONMENT_VARIABLES, "FIND_SPECIES_URL", "")
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.request_completed.connect(on_image_request_complete)
	http_request.request(url, headers, HTTPClient.METHOD_POST, data)
	
func on_image_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	pass
