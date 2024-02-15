extends Task

class_name CheckGroundType

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CheckGroundType") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	var tile_map_loc = bird.tile_map.local_to_map(bird.global_position)
	var tile_data = bird.tile_map.get_cell_tile_data(0, tile_map_loc)
	if tile_data == null:
		printerr("Tile loc is missing type data; ", tile_map_loc)
		return
	var type = tile_data.get_custom_data("Type")
	if bird.current_tile != type:
		bird.current_tile = type
		Logger.print_debug("[Current Tile]"+bird.current_tile, logger_key)
	super.success()
	
func start()->void:
	super.start()
