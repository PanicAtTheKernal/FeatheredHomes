extends Task

class_name FindNearestFood

var world_resources: WorldResources
var character_body: CharacterBody2D
var bird_range: float
var min_distance: float = 5

# TODO look at the perfromance under load, also there is an issue where the shortest distance may be to 
func run():
	var food_sources = world_resources.food_sources
	var distances: Array[float] = []
	var list_sources: Dictionary = {}
	var character_position: Vector2 = character_body.position
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

	#if shortest_distance <= min_distance:
	#	super.fail()
	#	return
	var new_target = list_sources[shortest_distance]
	print("New_target" + str(new_target))
	data["target"] = new_target
	# Disable the physics process until the navagation agents updated
	set_physics_process(false)
	super.success()
	return

func start():
	world_resources = data["world_resources"]
	character_body = data["character_body"]
	bird_range = data["range"]
