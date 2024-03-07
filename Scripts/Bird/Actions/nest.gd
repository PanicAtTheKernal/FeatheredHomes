extends Task

class_name Nest

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Nest") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		Logger.print_fail("Fail: Bird not at nest", logger_key)
		super.fail()
		return
	var nest_map_cords: Vector2i = bird.nest.position
	if bird.nest_manager.is_egg_laid(nest_map_cords) and bird.animatated_spite.finished != "nesting":
			bird.animatated_spite.play_nesting_animation()
			# The nesting animation loops indefinitely. Using the timer instead
			bird.behavioural_tree.pause_execution(3)
			Logger.print_running("Running: Bird is nesting", logger_key)
			super.running()
			return
	elif bird.animatated_spite.finished == "nesting":        
		bird.nest_manager.hatch_egg(nest_map_cords)
		Logger.print_success("Success: Egg hatched", logger_key)
		super.success()
	else:
		Logger.print_fail("Fail: Egg was not laid", logger_key)
		super.fail()
		return
	
func start()->void:
	super.start()
