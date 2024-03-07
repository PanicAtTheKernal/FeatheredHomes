extends Task

class_name FindNearestResource


var bird: Bird
var target_resource: String

func _init(parent_bird: Bird, resource_name: String, node_name: String="FindNearestResource") -> void:
	super(node_name)
	bird = parent_bird
	target_resource = resource_name

func run()->void:
	var bird_map_cords: Vector2 = bird.tile_map.world_to_map_space(bird.global_position)
	var shortest_distance = bird.find_shortest_path_min_heap(bird_map_cords, bird.current_partition, target_resource)
	# If no food is found then return fail
	if shortest_distance == null:
		shortest_distance = bird.check_closest_adjacent_cells(bird_map_cords, target_resource)
		if shortest_distance == null:
			Logger.print_fail(str("Fail: No ",target_resource," nearby "), logger_key)
			super.fail()
			return
	# Convert the shortest distance back into world space
	shortest_distance.value = bird.tile_map.map_to_world_space(shortest_distance.value)
	Logger.print_debug("[New target] "+str(shortest_distance.value), logger_key)
	bird.behavioural_tree.wait_for_function(bird.update_target.bind(shortest_distance.value))
	Logger.print_success(str("Success: Found ",target_resource," nearby "), logger_key)
	super.success()
