extends Node2D

class_name WorldResources

const TILE_SIZE = 16

@export
var food_resources: ProtoFood
@onready
var tile_map: TileMap = %TileMap
var food_sources: Array[FoodSource]

func _ready():
	var plants = tile_map.get_used_cells(1)
	for tile in plants:
		var tile_data = tile_map.get_cell_tile_data(1, tile)
		var tile_altas = tile_map.get_cell_atlas_coords(1, tile)
		var food_resource = food_resources.find_resource_by_id(tile_altas)
		# If no food resource was define for the tile then continue
		if food_resource == null:
			continue
		var value = tile_data.get_custom_data("Value")
		var amount = tile_data.get_custom_data("Amount")		
		if tile_data.get_custom_data("Tree") == "Empty":
			food_sources.append(FoodSource.new(food_resource, tile, "Empty", tile_map, 1, value, amount))
		elif tile_data.get_custom_data("Tree") == "Full":
			food_sources.append(FoodSource.new(food_resource, tile, "Full", tile_map, 1, value, amount))
	
	for food_source in food_sources:
		if food_source.current_state == "Empty":
			food_source.update_state("Full")

# This is only prototype code.
func _input(event):
	var update_states = {
		"Empty": "Full",
		"Full": "Empty"
	}
	# TODO Need to move this to player cam
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			var mouse_position = get_global_mouse_position()
			var mouse_position_to_tile_position = tile_map.local_to_map(mouse_position)
			for food_source in food_sources:
				if food_source.position == mouse_position_to_tile_position:
					var new_state = update_states[food_source.current_state]
					food_source.update_state(new_state)
					break

func update_food_state(loc: Vector2i, new_state: String)->FoodSource:
	for food_source in food_sources:
		if food_source.position == loc:
			food_source.update_state(new_state)
			# TODO Why? Food source will just be whatever the new_state is
			return food_source
	return null

func has_food(loc: Vector2i)->bool:
	for food_source in food_sources:
		if food_source.position == loc:
			if food_source.current_state == "Full":
				return true
	return false

func _on_regen_food_timeout():
	for food_source in food_sources:
		#Ignore food souce that still have food
		if food_source.current_state == "Full":
			continue
		var should_grow_food = randi_range(0, 10)
		if should_grow_food < 3:
			food_source.update_state("Full")
