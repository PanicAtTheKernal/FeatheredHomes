extends Task

class_name ReachedTarget

@export
var navigation_data: NavigationData

func run():
	if BirdHelperFunctions.character_at_target(navigation_data.character_body.global_position, data["target"]) == false:
		super.fail()
		return
	data["target_reached"] = false
	super.success()
	
func start():
	super.start()
