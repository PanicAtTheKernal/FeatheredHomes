extends Node2D

class_name NestManager

const FREE_NEST = "Free"
const TAKEN_NEST = "Taken"
const NESTS = "Nests"

var nests: Dictionary
@onready
var tile_map: TileMapManager = %TileMap
@onready
var world_resources: WorldResources = %WorldResources

func _ready() -> void:
	_initialise_nests()
	_get_nests()

func _initialise_nests() -> void:
	var nest_group_template = world_resources.get_resource_group_from_name(NESTS)
	for template in nest_group_template.resource_templates:
		nests[template.name] = {
			FREE_NEST: [],
			TAKEN_NEST: []
		}
		
func _get_nests() -> void:
	for partition in world_resources.resource_partitions.values():
		var nest_resources = partition[NESTS]
		for nest in nest_resources.values():
			nests[nest.template.name][FREE_NEST].push_back(nest)

func request_nest(nest_type: String) -> WorldResource:
	if nests[nest_type][FREE_NEST].size() > 0:
		var nest = nests[nest_type][FREE_NEST].pop_front()
		nests[nest_type][TAKEN_NEST].push_back(nest)
		return nest
	else:
		return null

func has_available_nest(nest_type: String) -> bool:
	return nests[nest_type][FREE_NEST].size() > 0

func build_nest(nest_map_cords: Vector2) -> bool:
	var nest = world_resources.get_resource("Nests", nest_map_cords)
	if nest != null and nest.current_state == "Empty":
		world_resources.set_resource_state(nest, "StartBuild")
		return false
	if nest != null and nest.current_state == "StartBuild":
		world_resources.set_resource_state(nest, "EmptyNest")
		return true
	if nest != null and nest.current_state == "EmptyNest":
		return true
	return false
	
func lay_egg(nest_map_cords: Vector2) -> bool:
	var nest = world_resources.get_resource("Nests", nest_map_cords)
	if nest != null and nest.current_state == "EmptyNest":
		world_resources.set_resource_state(nest, "Egg")
		return true
	return false
