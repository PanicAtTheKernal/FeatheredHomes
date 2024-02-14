extends Task

class_name FindRandomSpot

var bird: Bird

func _init(parent_bird, node_name:="FindRandomSpot") -> void:
	super(node_name)
	bird = parent_bird

func run():
	# TODO Fix the issue where the random spot can be on water
	var random_tile = BirdHelperFunctions.find_random_point_within_tile_map(bird.tile_map, bird.global_position, bird.species.flight_max_distance)
	var target = BirdHelperFunctions.calculate_tile_position(random_tile)
	bird.update_target(target)
	super.success()
	
func start():
	pass
