extends Task

class_name ConsumeFood

var tile_map: TileMap
@export
var navigation_data: NavigationData
var change_state

func run():
	if BirdHelperFunctions.character_at_target(navigation_data.character_body.global_position, data["target"]) == false:
		super.fail()
		return
	# Retrieve the resouces here instead of start just to make sure the resource are updated
	var world_resources: WorldResources = data["world_resources"]
	var target: Vector2 = data["target"]
	var tile_loc: Vector2i = tile_map.local_to_map(target)
	# Make sure that there is still food at the target location
	if world_resources.has_food(tile_loc):
		var tile = world_resources.update_food_state(tile_loc, "Empty")
		BirdHelperFunctions.add_caloires(tile.value, data)
		var direction = navigation_data.character_body.to_local(navigation_data.nav_agent.get_next_path_position()).normalized()
		var should_flip_h = direction.x < 0
		change_state.emit("Eat", should_flip_h)
		# Wait until the eating animation is completed before moving on
		set_physics_process(false)
	data["target_reached"] = false
	super.success()
	
func start():
	change_state = data["change_state"]
	tile_map = data["tile_map"]
