class_name BirdHelperFunctions

const TILE_SIZE = 16
const SPEED = 75**2

static func calculate_tile_position(target: Vector2i)->Vector2:
	return Vector2(target)*TILE_SIZE+(Vector2(TILE_SIZE/2.0, TILE_SIZE/2.0))

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
	var distance = target.distance_to(character_pos)
	if distance < 5.0:
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

static func find_random_point_within_tile_map(tile_map:TileMap)->Vector2:
	var tile_map_rect: Rect2i = tile_map.get_used_rect()
	# Take account of  the position of the tile map instead of just checking if the location is within the size
	var start = tile_map_rect.position
	var end = tile_map_rect.size + tile_map_rect.position 
	var point_x = randi_range(start.x, end.x)
	var point_y = randi_range(start.y, end.y)
	var tile_loc = Vector2i(point_x, point_y)
	return tile_loc
