extends Task

class_name CheckGroundType

var tile_map: TileMap
@export
var navigation_data: NavigationData
var character_body: CharacterBody2D
@export
var current_tile: String

func run():
	var tile_map_loc = tile_map.local_to_map(character_body.global_position)
	var tile_data = tile_map.get_cell_tile_data(0, tile_map_loc)
	if tile_data == null:
		printerr("Tile loc is missing type data; ", tile_map_loc)
		return
	var type = tile_data.get_custom_data("Type")
	if current_tile != type:
		current_tile = type
		print(current_tile)
	super.success()
	
func start():
	character_body = navigation_data.character_body
	tile_map = data["tile_map"]
	super.start()
