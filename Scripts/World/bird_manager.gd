extends Node2D

class_name BirdManager

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# create_bird()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_bird(bird_info: BirdInfo)->void:
	var new_bird: Bird = blank_bird.instantiate()
	setup_bird(new_bird, bird_info)
	create_traits(new_bird)
	add_bird(new_bird)
	
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

func create_traits(new_bird: Bird)->void:
	var trait_builder: TraitBuilder = TraitBuilder.new(new_bird)
	trait_builder.build_root()
	trait_builder.build_foraging()
	trait_builder.build_exploration()
