extends Node2D

class_name WorldResources

const TILE_SIZE = 16
const BIRD_RESOURCE = "Bird"

@export
var resource_templates_groups: Array[WorldResourceTemplateGroup]
@onready
var tile_map: TileMapManager = %TileMap
var resource_partitions: Dictionary
var template_atlas: Dictionary
var resource_counter: Dictionary
var resource_group_reference: Dictionary
var bird_partitions: Dictionary
var regenerate_groups: Array[String]

func _ready():
	_build_resource_dictionaries()
	_intialise_partition_resources()
	_get_resources_from_tile_map()

func _on_regen_food_timeout():
	for resource_partition in resource_partitions.values():
		for group in regenerate_groups:
			for resource in resource_partition[group].values():
				#Ignore food souce that still have food
				if resource.current_state == "Full":
					continue
				var should_grow_food = randf()
				if should_grow_food <= resource.template.respawn_rate:
					set_resource_state(resource, "Full")

func _build_resource_dictionaries() -> void:
	for template_group in resource_templates_groups:
		_initalise_template_atlas(template_group)
		_intialise_resource_counter(template_group)
		_intialise_resource_group_reference(template_group)
		_intialise_regenerative_resources(template_group)
		_intialise_bird_resources()
						
# Build a dictionary where the key is the atlas cords and the value is the template those atlas cords are used
# Speed up the search for specific template rather than going through each templates state sprites
func _initalise_template_atlas(template_group: WorldResourceTemplateGroup) -> void:
	template_atlas.merge(template_group.get_resources())

# Store a dictionary which stores the count each resource state in a resource group
# I.e Stores a count on how many food resources are on state "Empty" or "Full"
func _intialise_resource_counter(template_group: WorldResourceTemplateGroup) -> void:
	var counter_states = {}
	var states = template_group.get_states()
	for state in states:
		counter_states[state] = 0
	resource_counter[template_group.group_name] = counter_states

# Store which group each resource belongs to as easy to search dictonary. This is done since resource templates don't have a 
# refernce to their parent, so if I want to find which group a resource template belongs to, I would need to search 
# each group to see if the resource belongs there
func _intialise_resource_group_reference(template_group: WorldResourceTemplateGroup) -> void:
	for template in template_group.resource_templates:
		resource_group_reference[template] = template_group.group_name

func _intialise_regenerative_resources(template_group: WorldResourceTemplateGroup) -> void:
	# Don't add if already exists in the list
	if template_group.regenerate and not regenerate_groups.has(template_group.group_name):
		regenerate_groups.push_back(template_group.group_name)

func _intialise_bird_resources() -> void:
	for key in tile_map.partition_keys:
		bird_partitions[key] = []

func _intialise_partition_resources() -> void:
	for key in tile_map.partition_keys:
		var partition_dict = {}
		for resource_template_group in resource_templates_groups:
			partition_dict[resource_template_group.group_name] = {}
		resource_partitions[key] = partition_dict

func _get_resources_from_tile_map() -> void:
	var resource_tiles = tile_map.get_used_cells(1)
	for tile in resource_tiles:
		var tile_data = tile_map.get_cell_tile_data(1, tile)
		var tile_altas = tile_map.get_cell_atlas_coords(1, tile)
		# Find the resource template that belongs to the atlas cords
		if not template_atlas.has(tile_altas):
			continue
		var resource_template = template_atlas[tile_altas] as WorldResourceTemplate
		# If no resource template was define for the tile then continue
		if resource_template == null:
			continue
		var value = tile_data.get_custom_data("Value")
		var amount = tile_data.get_custom_data("Amount")
		var state = tile_data.get_custom_data("State")
		# Doesn't add a new resource if there is no state assigned in the tile map
		if state != "":
			var partition_index = tile_map.get_partition_index(tile)
			var resource_group = get_resource_group_name(resource_template)
			resource_counter[resource_group][state] += 1
			resource_partitions[partition_index][resource_group][tile] = WorldResource.new(resource_template, tile, state, tile_map, 1, value, amount)
			# Create the inital state for the resource
			set_resource_state(resource_partitions[partition_index][resource_group][tile], resource_template.initial_state)
			#

func get_resource(resource_group: String, map_cords: Vector2i) -> WorldResource:
	var partition_index = tile_map.get_partition_index(map_cords)
	if not resource_partitions.has(partition_index):
		return null
	var partition = resource_partitions[partition_index]
	if not partition.has(resource_group):
		return null
	var resource_group_part = partition[resource_group]
	if not resource_group_part.has(map_cords):
		return null
	return resource_group_part[map_cords]

func get_resource_from_loc(map_cords: Vector2i) -> WorldResource:
	var partition_index = tile_map.get_partition_index(map_cords)
	if not resource_partitions.has(partition_index):
		return null
	var partition = resource_partitions[partition_index]
	for group in partition.values():
		if group.has(map_cords):
			return group[map_cords]
	return null

func get_resource_partition_group(partition_index: Vector2i, group: String) -> Dictionary:
	if not resource_partitions.has(partition_index):
		return {}
	var partition = resource_partitions[partition_index]
	if not partition.has(group):
		return {}
	return partition[group]

func get_resource_group_name(resource: WorldResourceTemplate) -> String:
	if resource_group_reference.has(resource):
		return resource_group_reference[resource]
	else:
		return ""

func get_resource_group_from_name(group_name: String) -> WorldResourceTemplateGroup:
	for group in resource_templates_groups:
		if group.group_name == group_name:
			return group
	return null

func get_resource_group(resource: WorldResourceTemplate) -> WorldResourceTemplateGroup:
	for group in resource_templates_groups:
		if group.resource_templates.has(resource):
			return group
	return null

func can_resource_regenerate(resource: WorldResourceTemplate) -> bool:
	var group = get_resource_group(resource)
	if group == null:
		return false
	return group.regenerate

func add_resource(resource_group: String, map_cords: Vector2i, resource: Variant) -> void:
	var partition_index = tile_map.get_partition_index(map_cords)
	resource_partitions[partition_index][resource_group][map_cords] = resource
	# For some reason, it won't add the bird unless this line is here
	var magic_bird = resource_partitions[partition_index][resource_group][map_cords]
	return

func add_bird_resource(parition_index: Vector2i, old_index: Vector2i, bird: Bird) -> void:
	bird_partitions[old_index].erase(bird)
	bird_partitions[parition_index].push_back(bird)

func update_partition(old_map_cords: Vector2i, new_map_cords: Vector2i, group: String) -> void:
	var old_partition_key = tile_map.get_partition_index(old_map_cords)
	var new_partition_key = tile_map.get_partition_index(new_map_cords)
	var old_group = get_resource_partition_group(old_partition_key, group)
	var old_value = old_group[old_map_cords]
	old_group.erase(old_map_cords)
	get_resource_partition_group(new_partition_key, group)[new_map_cords] = old_value

func set_resource_state_from_loc(map_cords: Vector2i, new_state: String) -> void:
	var partition_key = tile_map.get_partition_index(map_cords)
	var groups = resource_partitions[partition_key]
	for group in groups.values():
		if group.has(map_cords):
			var resource: WorldResource = group[map_cords]
			set_resource_state(resource, new_state)
			break
		
func set_resource_state(resource: WorldResource, new_state: String) -> void:
	var old_state = resource.current_state
	if resource.update_state(new_state):
		var resource_group = get_resource_group_name(resource.template)
		resource_counter[resource_group][old_state] -= 1
		resource_counter[resource_group][new_state] += 1
		tile_map.update_resource_sprite(resource, new_state)
