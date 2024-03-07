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
	var nest_built = bird.nest_manager.is_nest_built(nest_map_cords) 
	var egg_laid = bird.nest_manager.is_egg_laid(nest_map_cords)
	if nest_built and not egg_laid:
		bird.nest_manager.lay_egg(nest_map_cords)
		Logger.print_success("Success: Egg was laid", logger_key)		
		super.success()
		return
	else:
		Logger.print_fail("Fail: Egg wasn't laid", logger_key)
		super.fail()
	
func start()->void:
	super.start()
