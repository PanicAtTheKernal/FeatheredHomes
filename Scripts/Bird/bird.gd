extends CharacterBody2D

class_name Bird

const TILE_SIZE = 16
const SPEED = 1500
const GROUND_COST = 50
const TAKE_OFF_COST = 100
const FLIGHT_COST = 20

@export
var target: Marker2D
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
var traits_built: bool = false

signal change_state(new_state: String, should_flip_h: bool)

#TODO create an inital state that count the path before the path is updated and use this inital state to determine if the bird should fly or not
#Maybe stop the timer and only start it when the path is set
func _ready():
	animatated_spite.sprite_frames = bird_species.bird_animations
	build_traits()	
	$NavigationTimer.autostart = true
	# Start the navaiagation timer at differnet times for each bird
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	$NavigationTimer.start()

func _process(delta):
	pass
	#var result = find_children("GroundSequence")
	#for node in result:
		#node.queue_free()

func _physics_process(_delta: float)->void:
	pass

func build_traits():
	var bird_traits = bird_species.bird_traits
	var global_traits = Database.traits
	
	# Wait for the global traits to load before modifing the tree
	while global_traits.size() == 0:
		await get_tree().create_timer(0.1).timeout	
		global_traits = Database.traits
	
	var test_trait = bird_traits[0]
	#var test_trait_rules = ["FreeRoamSequence", "CalculateDistances", "MovementSelector", "GroundSequence"]
	var test_trait_rules = global_traits[test_trait]["trait_rule"]
	var target_node: Node
	var target_found: bool = false
	var current_node_name: String = test_trait_rules.keys()[0]
	var current_dict = test_trait_rules
	var current_node = find_children(current_node_name)
	var next_node = current_dict.get(current_node_name).keys()[0]
	#print(test_trait_rule.keys())
	#for bird_trait in bird_traits:
	while !target_found:
		print(current_node_name)
		print(next_node)	
	
		current_dict = current_dict.get(current_node_name)
		current_node = find_children(current_node_name)
		if current_node.size() == 0:
			break
		current_node_name = next_node
		var next_node_value = current_dict.get(current_node_name)
		match typeof(next_node_value):
			TYPE_DICTIONARY:
				next_node = next_node_value.keys()[0]
			TYPE_ARRAY:
				target_found = true
				current_node = find_children(current_node_name)
				#target_node = current_node[0]
				break

	if target_node != null:
		print(target_node)
		print_tree_pretty()
		remove_child(target_node)
		target_node.free()

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
