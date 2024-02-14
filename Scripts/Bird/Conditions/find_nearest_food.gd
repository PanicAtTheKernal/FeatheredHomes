extends Task

class_name FindNearestFood


var bird: Bird

var min_distance: float = 5

func _init(parent_bird: Bird, node_name: String="CheckStamina") -> void:
	super(node_name)
	bird = parent_bird

# TODO look at the perfromance under load
func run():
	var food_sources = bird.world_resources.food_sources
	var distances: Array[float] = []
	var list_sources: Dictionary = {}
	var character_position: Vector2 = bird.global_position
	for food_source in food_sources:
		# Only add resouce that are full
		if food_source.current_state == "Empty":
			continue
		var position = BirdHelperFunctions.calculate_tile_position(food_source.position)
		var distance = character_position.distance_to(position)
		list_sources[distance] = position
		distances.append(distance)
	distances.sort()
	var shortest_distance = distances.pop_front()
	# If no food is found then return fail
	if shortest_distance == null:
		super.fail()
		return

	var new_target = list_sources[shortest_distance]
	print("New_target" + str(new_target))
	bird.update_target(new_target)

	# Might not need

	# Disable the physics process until the navagation agents updated
	# set_physics_process(false)
	super.success()
	return
