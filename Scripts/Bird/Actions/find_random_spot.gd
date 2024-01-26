extends Task

class_name FindRandomSpot

@export
var navigation_data: NavigationData

var tile_map: TileMap

func run():
	# TODO Fix the issue where the random spot can be on water
	var random_tile = BirdHelperFunctions.find_random_point_within_tile_map(tile_map, navigation_data.character_body.global_position, navigation_data.bird_species_info.bird_flight_max_distance)
	var target = BirdHelperFunctions.calculate_tile_position(random_tile)
	navigation_data.calulate_distance.update_target(target)
	super.success()
	
func start():
	tile_map = data["tile_map"]

