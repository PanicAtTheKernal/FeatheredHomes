extends TileMap

class_name TileMapManager

const TILE_SIZE = 16

@export_range(5,20)
var partition_size: int = 10

var partition_width: float
var partition_height: float
var partition_keys: Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_create_partitions()
	_create_partition_keys()

func _create_partitions()->void:
	var map_size = get_used_rect()
	partition_width = map_size.size.x/float(partition_size)
	partition_height = map_size.size.y/float(partition_size)

# Creating a 1D array of all the possible keys, which is used in the resource partition dictionary
func _create_partition_keys() -> void:
	for i in range(partition_size):
		for j in range(partition_size):
			partition_keys.push_back(Vector2i(i, j))
			


func update_resource_sprite(resource: WorldResource, new_state: String)->void:
	var resource_state: ResourceState = resource.template.get_state(new_state)
	if resource_state == null:
		return
	set_cell(resource.layer, resource.position, resource_state.source_id, resource_state.altas_cords, resource_state.alternative_tile)

func get_partition_index(map_cords: Vector2)->Vector2i:
	return Vector2i(floori(map_cords.x/partition_width), floori(map_cords.y/partition_height))

func world_to_map_space(world_cords: Vector2)->Vector2i:
	return local_to_map(world_cords)

func map_to_world_space(map_cords: Vector2i)->Vector2:
	return map_to_local(map_cords)
	
func check_if_within_bounds(world_cords: Vector2)->bool:
	var tile_loc = world_to_map_space(world_cords)
	return check_if_within_map_bounds(tile_loc)

func check_if_within_map_bounds(map_cords: Vector2i)->bool:
	var tile_map_rect: Rect2i = get_used_rect()
	# Take account of  the position of the tile map instead of just checking if the location is within the size
	var start = tile_map_rect.position
	var end = tile_map_rect.size + tile_map_rect.position 
	if (map_cords > start) and (map_cords < end):
		return true
	else:
		return false

func check_if_within_partition_bounds(partition_index: Vector2i)->bool:
	if (partition_index.x > partition_keys[0].x) and (partition_index.x < partition_keys[-1].x) and (partition_index.y > partition_keys[0].y) and (partition_index.y < partition_keys[-1].y):
		return true
	else:
		return false 

func get_partition_midpoint(partition_index: Vector2i)->Vector2:
	var midpoint_width = (partition_index.x*self.partition_width) + self.partition_width/2
	var midpoint_height = (partition_index.y*self.partition_height) + self.partition_height/2
	return Vector2(midpoint_width, midpoint_height)
