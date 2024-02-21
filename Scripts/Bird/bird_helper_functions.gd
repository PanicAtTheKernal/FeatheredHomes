class_name BirdHelperFunctions

const TILE_SIZE = 16
const SPEED = 40**2

static func calculate_tile_position(target: Vector2i)->Vector2:
	return Vector2(target)*TILE_SIZE+(Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0))

static func calculate_map_position(target: Vector2)->Vector2i:
	return Vector2i(target/TILE_SIZE-(Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0)))

static func total_distance_vect(path: Array[Vector2])->Vector2:
	var total: Vector2 =  Vector2(0,0)
	for path_node in path:
		total += path_node
	return total

static func total_distance(path: Array[Vector2])->float:
	var total: float = 0.0
	var path_len = len(path)
	if path_len <= 1:
		return 0.0
	var current_node:Vector2 = path.pop_front()
	for path_node in path:
		total += current_node.distance_to(path_node)
		current_node = path_node
	return total

static func calculate_energy_cost(distance: float, take_off_cost: float, energy_cost: float)->float:
	return (distance*energy_cost)+take_off_cost

static func calculate_time_to_target(_path: Array[Vector2]):
	pass

static func burn_caloires(amount:float, data: Dictionary):
	data["stamina"] = clamp(data["stamina"] - amount, 0, data["max_stamina"])
	
static func add_caloires(amount:float, data: Dictionary):
	data["stamina"] = clamp(data["stamina"] + amount, 0, data["max_stamina"])

# Function to make sure the bird is at the target
static func character_at_target(character_pos: Vector2, target: Vector2)->bool:
	# Round the number to the nearest whole number because float precision was causing accuracy issues 
	var character_pos_rounded = round(character_pos)
	var target_rounded = round(target)
	var test = (character_pos_rounded - target_rounded).length()
	if test < 5.0:
		return true
	else:
		return false

static func find_tile_type(loc: Vector2, flip_h: bool, data: Dictionary):
	var tile_map = data["tile_map"]
	var tile_map_loc = tile_map.local_to_map(loc)
	var tile_data = tile_map.get_cell_tile_data(0, tile_map_loc)
	if tile_data == null:
		printerr("Tile loc is missing type data; ", tile_map_loc)
		return
	var type = tile_data.get_custom_data("Type")
	if data["current_ground"] != type:
		data["change_state"].emit(type, flip_h)
		data["current_ground"] = type

static func check_if_within_bounds(loc: Vector2, tile_map:TileMap)->bool:
	var tile_map_rect: Rect2i = tile_map.get_used_rect()
	var tile_loc = tile_map.local_to_map(loc)
	# Take account of  the position of the tile map instead of just checking if the location is within the size
	var start = tile_map_rect.position
	var end = tile_map_rect.size + tile_map_rect.position 
	if (tile_loc > start) and (tile_loc < end):
		return true
	else:
		return false

static func find_random_point_within_tile_map(tile_map:TileMap, starting_loc: Vector2, range: float)->Vector2:
	var tile_map_rect: Rect2i = tile_map.get_used_rect()
	var tile_range: float = range/2
	var tile_start_loc: Vector2i = calculate_map_position(starting_loc)
	var start = tile_map_rect.position
	var end = tile_map_rect.size + tile_map_rect.position 
	# Make the range is within the bounds of the map, add/sub one to each edge bound to prevent the target being on the edge
	var min_x = tile_start_loc.x-tile_range if (tile_start_loc.x-tile_range) > (start.x+1) else start.x+1
	var max_x = tile_start_loc.x+tile_range if (tile_start_loc.x+tile_range) < (end.x-1) else end.x-1
	var min_y = tile_start_loc.y-tile_range if (tile_start_loc.y-tile_range) > (start.y+1) else start.y+1
	var max_y = tile_start_loc.y+tile_range if (tile_start_loc.y+tile_range) < (end.y-1) else end.y-1

	randomize()
	var point_x = randi_range(min_x, max_x*TILE_SIZE)
	var point_y = randi_range(min_y, max_y*TILE_SIZE)
	var tile_loc = Vector2i(point_x, point_y)
	return tile_loc
