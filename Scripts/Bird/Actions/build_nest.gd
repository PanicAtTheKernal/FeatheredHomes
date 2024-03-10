extends Task

class_name BuildNest

var bird: Bird
var nest_finished = false

func _init(parent_bird: Bird, node_name:String="BuildNest") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		Logger.print_fail("Fail: Bird not at nest", logger_key)
		super.fail()
		return
	if bird.nest == null:
		Logger.print_fail("Fail: Nest is gone", logger_key)
		super.fail()
		return
	var nest_map_cords: Vector2i = bird.nest.position
	bird.nest_manager.build_nest(nest_map_cords)
	if bird.nest_manager.is_nest_built(nest_map_cords):
		Logger.print_success("Success: Nest built", logger_key)		
		super.success()
	else:
		Logger.print_fail("Fail: Nest not built", logger_key)
		super.fail()
		return
	
func start()->void:
	super.start()
