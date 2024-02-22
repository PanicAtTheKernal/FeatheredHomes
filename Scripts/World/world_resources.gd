extends Node2D

class_name WorldResources

const TILE_SIZE = 16

@export
var resource_templates_groups: Array[WorldResourceTemplateGroup]
@onready
var tile_map: TileMapManager = %TileMap
var resources: Dictionary
var template_atlas: Dictionary
var resource_counter: Dictionary
var resource_group_reference: Dictionary

func _ready():
	_build_resource_dictionaries()
	_get_resources_from_tile_map()

	# TODO: Remove this, its only used for testing
	for resource in resources.values():
		if resource.current_state == "Empty":
			set_resource_state(resource, "Full")

func _on_regen_food_timeout():
	for resource in resources.values():
		#Ignore food souce that still have food
		if resource.current_state == "Full":
			continue
		var should_grow_food = randi_range(0, 10)
		if should_grow_food < 3:
			set_resource_state(resource, "Full")

func _build_resource_dictionaries()->void:
	for template_group in resource_templates_groups:
		_initalise_template_atlas(template_group)
		_intialise_resource_counter(template_group)
		_intialise_resource_group_reference(template_group)

						
# Build a dictionary where the key is the atlas cords and the value is the template those atlas cords are used
# Speed up the search for specific template rather than going through each templates state sprites
func _initalise_template_atlas(template_group: WorldResourceTemplateGroup)->void:
	template_atlas.merge(template_group.get_resources())

# Store a dictionary which stores the count each resource state in a resource group
# I.e Stores a count on how many food resources are on state "Empty" or "Full"
func _intialise_resource_counter(template_group: WorldResourceTemplateGroup)->void:
	var counter_states = {}
	var states = template_group.get_states()
	for state in states:
		counter_states[state] = 0
	resource_counter[template_group.group_name] = counter_states

# Store which group each resource belongs to as easy to search dictonary. This is done since resource templates don't have a 
# refernce to their parent, so if I want to find which group a resource template belongs to, I would need to search 
# each group to see if the resource belongs there
func _intialise_resource_group_reference(template_group: WorldResourceTemplateGroup)->void:
	for template in template_group.resource_templates:
		resource_group_reference[template] = template_group.group_name

func _get_resources_from_tile_map()->void:
	var resource_tiles = tile_map.get_used_cells(1)
	for tile in resource_tiles:
		var tile_data = tile_map.get_cell_tile_data(1, tile)
		var tile_altas = tile_map.get_cell_atlas_coords(1, tile)
		# Find the resource that belongs to the atlas cords
		if not template_atlas.has(tile_altas):
			continue 
		var resource = template_atlas[tile_altas]
		# If no food resource was define for the tile then continue
		if resource == null:
			continue
		var value = tile_data.get_custom_data("Value")
		var amount = tile_data.get_custom_data("Amount")
		var state = tile_data.get_custom_data("State")	
		if state != "":	
			# Partition code goes here
			var resource_group = get_resource_group(resource)
			resource_counter[resource_group][state] += 1
			resources[tile] = WorldResource.new(resource, tile, state, tile_map, 1, value, amount)

func get_resource(loc: Vector2i)->WorldResource:
	if not resources.has(loc): 
		return null
	return resources[loc]

func get_resource_group(resource: WorldResourceTemplate)->String:
	if resource_group_reference.has(resource):
		return resource_group_reference[resource]
	else:
		return ""

func set_resource_state_from_loc(loc: Vector2i, new_state: String)->void:
	var resource: WorldResource = resources[loc]
	if resource == null:
		return
	set_resource_state(resource, new_state)
		
func set_resource_state(resource: WorldResource, new_state: String)->void:
	var old_state = resource.current_state
	if resource.update_state(new_state):
		var resource_group = get_resource_group(resource.template) 
		resource_counter[resource_group][old_state] -= 1
		resource_counter[resource_group][new_state] += 1
		tile_map.update_resource_sprite(resource, new_state)
