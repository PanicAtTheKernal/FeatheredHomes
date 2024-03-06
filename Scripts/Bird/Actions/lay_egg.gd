extends Task

class_name LayEgg

var bird: Bird

func _init(parent_bird: Bird, node_name:String="LayEgg") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		Logger.print_fail("Fail: Bird not at nest", logger_key)
		super.fail()
		return
	var nest_map_cords: Vector2i = bird.nest.position
	if bird.nest_manager.is_nest_built(nest_map_cords) and not bird.nest_manager.is_egg_laid(nest_map_cords):
		bird.nest_manager.lay_egg(nest_map_cords)
		Logger.print_success("Success: Egg was laid", logger_key)		
		super.success()
	else:
		Logger.print_fail("Fail: Egg wasn't laid", logger_key)
		super.fail()
		return
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
