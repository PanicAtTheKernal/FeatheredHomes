extends Node2D

class_name BirdManager

const MAX_STAMINA = 10000
const MIN_STAMINA = 500
const MAX_GROUND_DISTANCE = 10
const MIN_GROUND_DISTANCE = 4
const MAX_FLIGHT_DISTANCE = 30

@export
var blank_bird: PackedScene = preload("res://BlankBird.tscn")
@export
var default_bird: BirdSpecies
@export
var default_info: BirdInfo

@onready
var player_camera: Camera2D = %PlayerCam
@onready
var tilemap:TileMap = %TileMap
@onready
var world_resources: WorldResources = $"../WorldResources"

var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "BirdManager"
}

func create_bird(bird_info: BirdInfo)->void:
	var new_bird: Bird = blank_bird.instantiate()
	setup_bird(new_bird, randomise_stats(bird_info))
	create_traits(new_bird)
	add_bird(new_bird)
	
func randomise_stats(bird_info:BirdInfo)->BirdInfo:
	bird_info.species.max_stamina = randf_range(MIN_STAMINA, MAX_STAMINA)
	bird_info.species.stamina = randf_range(MIN_STAMINA, bird_info.species.max_stamina)
	bird_info.species.ground_max_distance = randf_range(MIN_GROUND_DISTANCE, MAX_GROUND_DISTANCE)
	bird_info.species.flight_max_distance = randf_range(bird_info.species.ground_max_distance, MAX_FLIGHT_DISTANCE)
	return bird_info

func setup_bird(new_bird:Bird, bird_info: BirdInfo)->void:
	new_bird.species = bird_info.species
	new_bird.tile_map = tilemap
	new_bird.world_resources = world_resources
	new_bird.info = bird_info
	new_bird.id = get_child_count()+1

func add_bird(new_bird: Bird)->void:
	new_bird.global_position = player_camera.get_screen_center_position()
	Logger.print_debug("New bird has been added ID: "+str(new_bird.id), logger_key)
	add_child(new_bird)
	get_tree().call_group("Dialog", "display", str("You found a ",new_bird.info.species.name.capitalize()))
	get_tree().call_group("LoadingButton", "hide_loading")

func create_traits(new_bird: Bird)->void:
	var trait_builder: TraitBuilder = TraitBuilder.new(new_bird)
	trait_builder.build_root()
	trait_builder.build_foraging()
	trait_builder.build_exploration()
