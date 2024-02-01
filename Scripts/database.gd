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

func send_image_request(image: PackedByteArray):
	var auth_header = "Authorization: Bearer " + config.get_value(ENVIRONMENT_VARIABLES, "ANON_TOKEN", "")
	var content_type_header = "Content-Type: application/octet-stream"
	var headers = [auth_header, content_type_header]
	var url = config.get_value(ENVIRONMENT_VARIABLES, "URL", "") + config.get_value(ENVIRONMENT_VARIABLES, "IMAGE_ENDPOINT", "")
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.request_completed.connect(on_image_request_complete)
	add_child(http_request)
	http_request.request_raw(url, headers, HTTPClient.METHOD_POST, image)
	
func on_image_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if result != HTTPClient.RESPONSE_OK:
		printerr(body.get_string_from_utf8())
	var result_body = JSON.parse_string(body.get_string_from_ascii())
	get_tree().call_group("Dialog", "display", ("You found a "+result_body.get("birdSpecies")))
	get_tree().call_group("LoadingButton", "hide_loading")
	
