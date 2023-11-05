extends Task

class_name ConsumeFood

var tile_map: TileMap
var character_body: CharacterBody2D

func run():
	if BirdHelperFunctions.character_at_target(character_body.global_position, data["target"]) == false:
		super.fail()
		return
	# Retrieve the resouces here instead of start just to make sure the resource are updated
	var world_resources: WorldResources = data["world_resources"]
	var target: Vector2 = data["target"]
	var tile_loc: Vector2i = tile_map.local_to_map(target)
	var tile = world_resources.update_food_state(tile_loc, "Empty")
	if tile != null:
		BirdHelperFunctions.add_caloires(tile.value, data)
	data["target_reached"] = false
	super.success()
	
func start():
	character_body = data["character_body"]
	tile_map = data["tile_map"]
