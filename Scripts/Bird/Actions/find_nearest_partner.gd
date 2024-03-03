extends Task

class_name FindNearestBird


var bird: Bird

func _init(parent_bird: Bird, node_name: String="FindNearestBird") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.partner != -1:
		super.success()
		return
	# bird.middle_of_love = true
	# A partner is invalid, if it's not the opposite gender, not too young, not the same species
	var partner_condition = func(nearby_bird) : 
		return (bird.info.gender == nearby_bird.info.gender) or (nearby_bird.current_age < 4) or (bird.species.name != nearby_bird.species.name) or (bird.partner == nearby_bird.id) or (nearby_bird.nest != null) or (not nearby_bird.mate) or (nearby_bird.partner != -1)
	var shortest_distance =  bird.find_nearest_bird(partner_condition, bird.current_partition)
	if shortest_distance == null:
		shortest_distance = bird.check_closest_adjacent_cells_bird(partner_condition)
		if shortest_distance == null:
			super.fail()
			return
	# Place the target beside the female bird but place based on the direction of the male bird 
	var offset = bird.global_position.direction_to(shortest_distance.value.global_position) * 15
	offset.y = 0
	var location = shortest_distance.value.global_position - offset
	shortest_distance.value.listener.emit(bird.BirdCalls.STOP, bird.id, bird.global_position)
	bird.partner = shortest_distance.value.id
	
	# TODO Temp logger stuff
	logger_key.type = Logger.LogType.NAVIGATION
	Logger.print_debug("[New Partner] "+str(location), logger_key)
	await bird.update_target(location)
	super.success()
