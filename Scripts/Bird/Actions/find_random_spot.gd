extends Task

class_name FindRandomSpot

var tile_map: TileMap

func run():
	var random_tile = BirdHelperFunctions.find_random_point_within_tile_map(tile_map)
	var target = BirdHelperFunctions.calculate_tile_position(random_tile)
	data["target"] = target
	super.success()
	
func start():
	tile_map = data["tile_map"]
