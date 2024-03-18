extends Node2D

class_name BirdManager

const MAX_STAMINA = 10000
const MIN_STAMINA = 500
const MAX_GROUND_DISTANCE = 40
const MIN_GROUND_DISTANCE = 20
const MAX_FLIGHT_DISTANCE = 200
const MIN_AGE = 20
const MAX_AGE = 30
const MIN_FOOD_THRESHOLD = 0.2
const MAX_FOOD_THRESHOLD = 0.9

@export
var blank_bird: PackedScene = preload("res://BlankBird.tscn")
@export
var default_bird: BirdSpecies
@export
var default_info: BirdInfo

@onready
var player_camera: Camera2D = %PlayerCam
@onready
var tile_map:TileMapManager = %TileMap
@onready
var world_resources: WorldResources = $"../WorldResources"
@onready
var nest_manager: NestManager = %NestManager

var partitions: Dictionary : 
	get:
		return partitions
var save_thread: Thread
var thread_running: bool

var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdManager"
}

@onready
var female: BirdInfo = ResourceLoader.load("res://Assets/Birds/NewBird/DUNNOCK-FEMALE-INFO.tres")
@onready
var male: BirdInfo = ResourceLoader.load("res://Assets/Birds/NewBird/DUNNOCK-MALE-INFO.tres") 

func _ready() -> void:
	_intialise_bird_resources()
	_load_birds()
	save_thread = Thread.new()
	
	#for i in range(20):
		#BirdResourceManager.add_bird("Dunnock")
	#for i in range(15):
		#BirdResourceManager.add_bird("Blue tit")
	#for i in range(1):
		#var fem_bird = create_bird(female)
		#add_bird(fem_bird)
		#var man_bird = create_bird(male)
		#add_bird(man_bird)
	
func _intialise_bird_resources() -> void:
	for key in tile_map.partition_keys:
		partitions[key] = []

func _load_birds() -> void:
	if len(PlayerResourceManager.player_data.birds) < 1:
		return
	for bird_state: BirdState in PlayerResourceManager.player_data.birds:
		var bird_info = BirdResourceManager.load_bird(bird_state.species_name, bird_state.gender)
		bird_info.species = bird_state.species
		var bird = create_bird(bird_info)
		spawn_bird(bird, bird_state.position)
		bird.current_stamina = bird_state.species.stamina
		BirdResourceManager.add_bird_to_list(bird_info)
	PlayerResourceManager.player_data.birds = []

func create_bird(bird_info: BirdInfo)->Bird:
	var new_bird: Bird = blank_bird.instantiate()
	setup_bird(new_bird, randomise_stats(bird_info))
	create_traits(new_bird)
	return new_bird
	
func randomise_stats(bird_info:BirdInfo)->BirdInfo:
	bird_info.species.max_stamina = randf_range(MIN_STAMINA, MAX_STAMINA)
	# TODO Temp
	bird_info.species.stamina = randf_range(100, bird_info.species.max_stamina)
	bird_info.species.ground_max_distance = randf_range(MIN_GROUND_DISTANCE, MAX_GROUND_DISTANCE)
	bird_info.species.flight_max_distance = randf_range(bird_info.species.ground_max_distance, MAX_FLIGHT_DISTANCE)
	bird_info.species.max_age = randi_range(MIN_AGE, MAX_AGE)
	bird_info.species.threshold = randf_range(MIN_FOOD_THRESHOLD, MAX_FOOD_THRESHOLD)
	return bird_info

func setup_bird(new_bird:Bird, bird_info: BirdInfo)->void:
	new_bird.species = bird_info.species
	new_bird.tile_map = tile_map
	new_bird.world_resources = world_resources
	new_bird.nest_manager = nest_manager
	new_bird.bird_manager = self
	new_bird.info = bird_info
	new_bird.id = bird_info.create_unique_id()
	new_bird.scale = new_bird.scale * bird_info.species.size
	new_bird.sound_player.stream = Startup.bird_sounds[bird_info.species.sound]
	new_bird.logger_key.obj = "("+str(new_bird.id)+": Bird)"
	# TODO Testing setup for bird mating/parenting
	new_bird.current_age = 4

func spawn_bird(new_bird: Bird, location: Vector2)->void:
	new_bird.global_position = location
	Logger.print_debug("New bird has been added ID: "+str(new_bird.id), logger_key)
	Logger.create_new_bird_log(new_bird.id)
	add_child(new_bird)

func add_bird(new_bird: Bird, random_bird: bool = false)->void:
	spawn_bird(new_bird, player_camera.get_screen_center_position())
	# TODO REMOVE THIS 
	#if new_bird.info.gender == "female":
		#new_bird.global_position.x += 75
	var message = "You found a "+new_bird.info.species.name.capitalize()
	if random_bird:
		message = "You get a "+new_bird.info.species.name.capitalize()+" because the exact bird species can't be determined"
	get_tree().call_group("Dialog", "display", message, "Congratulations!", true)
	get_tree().call_group("LoadingButton", "hide_loading")

func create_traits(new_bird: Bird)->void:
	var trait_builder: TraitBuilder = TraitBuilder.new(new_bird)
	trait_builder.build_root()
	trait_builder.build_partner()
	trait_builder.build_nest_building()
	trait_builder.build_parenting()
	# This is below partner and parenting because foraging and wander have very few condiditons to be active
	trait_builder.build_foraging()
	trait_builder.build_exploration()

func get_bird(id: int)->Bird:
	for bird in get_children():
		if bird.id == id:
			return bird
	return null

func add_bird_resource(parition_index: Vector2i, old_index: Vector2i, bird: Bird) -> void:
	partitions[old_index].erase(bird)
	partitions[parition_index].push_back(bird)

func save_all_birds() ->void:
	for bird: Bird in get_children():
		var bird_state: BirdState = BirdState.new()
		bird_state.position = bird.global_position
		bird_state.age = bird.current_age
		bird_state.species = bird.species
		bird_state.species.stamina = bird.current_stamina
		bird_state.species_name = bird.species.name
		bird_state.gender = bird.info.gender
		PlayerResourceManager.player_data.birds.push_back(bird_state)
		PlayerResourceManager.save_player_data()

func _exit_tree():
	save_thread.wait_to_finish()

func _save_all_birds()->void:
	PlayerResourceManager.player_data.birds = []
	save_thread.set_thread_safety_checks_enabled(false)
	Thread.set_thread_safety_checks_enabled(false)
	

