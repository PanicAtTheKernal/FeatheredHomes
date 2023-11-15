extends CanvasLayer

@export
var bird_scene: PackedScene

@export
var world_rescources: WorldResources
@export
var player_cam: Camera2D
@export
var tile_map: TileMap

@onready
var line_edit := $HBoxContainer/BirdNameLineEdit as LineEdit

@onready
var find_species_request := $FindSpeciesRequest as HTTPRequest
var config

const ASSET_PATH = "res://Assets/Download/"
const ENVIRONMENT_VARIABLES = "environment" 

# Called when the node enters the scene tree for the first time.
func _ready():
	config = load_env_file()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var users_bird_name = line_edit.text
	if users_bird_name == "":
		print("User didn't enter bird name")
		
	var bird_species_file = find_potential_files(line_edit.text)
	line_edit.clear()
	if bird_species_file != "":
		var bird_species_resource: BirdSpecies = load(ASSET_PATH + bird_species_file)
		var bird = bird_scene.instantiate()
		var center_pos = player_cam.get_screen_center_position()
		bird.bird_species = bird_species_resource
		bird.position = center_pos
		bird.tile_map = tile_map
		bird.world_resources = world_rescources
		
		get_parent().add_child(bird)
	else:
		get_bird_from_cloud(users_bird_name)
		
	

func find_potential_files(bird_name: String) -> String:
	# The species rescoure files don't use spaces, files instead use hyphens
	var bird_file_name = bird_name.replace(" ", "-")
	var files = DirAccess.get_files_at(ASSET_PATH)
	var file_regex = RegEx.new()
	file_regex.compile("[^*]*"+bird_file_name+"[^*]*[.]tres")
	for file in files:
		if file_regex.search(file):
			return file
	return ""

func get_bird_from_cloud(bird_name: String):
	# Don't make the request if the env file didn't load in
	if config == null:
		return
	var data = JSON.stringify({name:"Functions"})
	var auth_header = "Authorization: Bearer " + config.get_value(ENVIRONMENT_VARIABLES, "ANON_TOKEN", "")
	var content_type_header = "Content-Type: application/json"
	var headers = [auth_header, content_type_header]
	# Encode all spaces with the url space code value 
	var url_bird_name = bird_name.replace(" ", "%20")
	var find_species_url = config.get_value(ENVIRONMENT_VARIABLES, "FIND_SPECIES_URL", "") + "?species=" + url_bird_name
	find_species_request.request_completed.connect(find_species_request_result)
	find_species_request.request(find_species_url, headers, HTTPClient.METHOD_POST, data)

func load_env_file() -> ConfigFile:
	var config = ConfigFile.new()
	var error = config.load("res://.env")
	if error != OK:
		print("Could not load env file")
		return null
	return config
	
func find_species_request_result(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("1: "+ str(result))
	print("2: "+ str(response_code))
	print("3: "+ str(headers))
	print("4: "+ body.get_string_from_ascii())
	if response_code == 200:
		build_simulation(JSON.parse_string(body.get_string_from_ascii()))
	else:
		print("There was an error retriving the data")

func build_simulation(request_body: Dictionary):
	var body: Dictionary = request_body.get("data")
	var new_species: BirdSpecies = BirdSpecies.new()
	var name = body.get("birdName")
	var simulation_info: Dictionary = body.get("birdSimulationInfo")
	var bird_shape_id: String = body.get("birdShapeId")
	var bird_template_url: String = body.get("birdImageUrl")
	
	var animations = await build_animation(bird_shape_id, bird_template_url)
	# If failed to build animation then return and not create the resource
	if animations == null:
		return
	new_species.bird_animations = animations
	new_species.bird_flight_cost = simulation_info.get("birdFlightCost")
	new_species.bird_ground_cost = simulation_info.get("birdGroundCost")
	new_species.bird_max_stamina = simulation_info.get("birdMaxStamina")
	new_species.bird_range = simulation_info.get("birdRange")
	new_species.bird_stamina = simulation_info.get("birdStamina")
	new_species.bird_take_off_cost = simulation_info.get("birdTakeOffCost")
	
	for bird_trait in simulation_info.get("birdTraits"):
		new_species.bird_traits.append(bird_trait)

func build_animation(shape_id: String, template_url: String) -> SpriteFrames:
	var image_name_index = template_url.rfind("BirdAssets")
	var image_name = template_url.substr(image_name_index).replace("BirdAssets/", "")	
	var image_file_name = image_name.split("/")[1]
	
	var email = config.get_value(ENVIRONMENT_VARIABLES, "EMAIL")
	var password = config.get_value(ENVIRONMENT_VARIABLES, "PASSWORD")
	var sign_result: AuthTask = await Supabase.auth.sign_in(email, password).completed
	if sign_result.user != null:
		printerr("Failed to sign in")
		return null
	
	var animationTemplateQuery: SupabaseQuery = SupabaseQuery.new().from("BirdShape").select().eq("BirdShapeId", shape_id)
	var animationTemplateResult = await Supabase.database.query(animationTemplateQuery).completed
	var animatinoTemplate = animationTemplateResult.data[0]["BirdShapeAnimationTemplate"]
	var storageResult: StorageTask = await Supabase.storage.from("BirdAssets").download(image_name, ASSET_PATH + image_file_name).completed
	
	if storageResult.error != null:
		printerr(storageResult.error)
	
	return SpriteFrames.new()
	

