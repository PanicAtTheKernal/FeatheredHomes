extends CharacterBody2D

const TILE_SIZE = 16
const SPEED = 1500
const GROUND_COST = 50
const TAKE_OFF_COST = 100
const FLIGHT_COST = 20

@export
var target: Vector2i
@export
var tile_map: TileMap
@export
var bird_species: BirdSpecies
@export
var world_resources: WorldResources
@onready
var nav_agent:= $GroundAgent as NavigationAgent2D
@onready
var fly_agent:= $FlightAgent as NavigationAgent2D
@onready
var animatated_spite := $AnimatedSprite2D as AnimatedSprite2D


var proper_target: Vector2
var current_ground: String = "Ground"
var is_flying: bool = false
var prefered_agent: NavigationAgent2D

signal change_state(new_state: String, should_flip_h: bool)

#TODO create an inital state that count the path before the path is updated and use this inital state to determine if the bird should fly or not
#Maybe stop the timer and only start it when the path is set
func _ready():
	animatated_spite.sprite_frames = bird_species.bird_animations
	$NavigationTimer.autostart = true
	# Start the navaiagation timer at differnet times for each bird
	await get_tree().create_timer(randf_range(0.1, 3.0)).timeout
	$NavigationTimer.start()

func _physics_process(_delta: float)->void:
	# If no path was found skip the update
	# TODO FIX THIS
	#if prefered_agent.get_next_path_position() == Vector2(0,0):
	#	return
	
	#print(is_flying)
	
	#if is_flying == false:
	#	check_ground()
		
	#check_target()
	
	#var direction = to_local(prefered_agent.get_next_path_position()).normalized()
	#velocity = direction * SPEED * delta
	
	#if prefered_agent.is_target_reached() == false:
	#	move_and_slide()
	#else:
	#	is_flying = false
	pass

func make_path()->void:
	pass
	#fly_agent.set_navigation_map(tile_map.get_navigation_map(1))
	#nav_agent.target_position = proper_target
	#fly_agent.target_position = proper_target

	

func calc_distance_to_tiles()->float:
	return 0.0

func select_movement()->void:
	return

func check_target()->void:
	# Don't update the preferred_agent if destination is reached
	if prefered_agent.is_target_reached():
		return
	
	# Path does not get calcuated until this function is called
	nav_agent.get_next_path_position()
	fly_agent.get_next_path_position()
	var nav_dist = total_distance(nav_agent.get_current_navigation_result().path)
	var fly_dist = total_distance(fly_agent.get_current_navigation_result().path)
	# TODO REPLACE WITH THE WEIGHT FORMULA
	if (fly_dist <= nav_dist and fly_agent.is_target_reachable()) or (nav_agent.is_target_reachable() == false):
		prefered_agent = fly_agent
		change_state.emit("Flying")
		is_flying = true
		current_ground = "Sky"
		set_collision_mask_value(1, false)
	else:
		prefered_agent = nav_agent
		set_collision_mask_value(1, true)
## This function look through all the navigation layers to find the shortest path

func total_distance(path: Array[Vector2])->Vector2:
	var total: Vector2 =  Vector2(0,0)
	for path_node in path:
		total += path_node
	return total

func check_ground():
	var current_position: Vector2 = position
	var tile_position = tile_map.local_to_map(current_position)
	var tile_data = tile_map.get_cell_tile_data(0, tile_position)
	if tile_data == null:
		print("null")
		return
	var type = tile_data.get_custom_data("Type")
	if current_ground != type:
		change_state.emit(type)
	current_ground = type

func _on_wait_timeout():
	pass # Replace with function body.
