extends Node2D

class_name NestManager

const FREE_NEST = "Free"
const TAKEN_NEST = "Taken"
const NESTS = "Nests"

var nests: Dictionary
@onready
var tile_map: TileMapManager = %TileMap
@onready
var world_rescources: WorldResources = %WorldResources

func _ready() -> void:
	_initialise_nests()
	_get_nests()

func _initialise_nests() -> void:
	var nest_group_template = world_rescources.get_resource_group_from_name(NESTS)
	for template in nest_group_template.resource_templates:
		nests[template.name] = {
			FREE_NEST: [],
			TAKEN_NEST: []
		}
		
func _get_nests() -> void:
	for partition in world_rescources.resource_partitions.values():
		var nest_resources = partition[NESTS]
		for nest in nest_resources.values():
			nests[nest.template.name][FREE_NEST].push_back(nest)

func request_nest(nest_type: String) -> WorldResource:
	if nests[nest_type][FREE_NEST].size() > 0:
		var nest = nests[nest_type][FREE_NEST].pop_back()
		nests[nest_type][TAKEN_NEST].push_back(nest)
		return nest
	else:
		return null
