extends Task

class_name CheckIfReachedTarget

var is_target_reached: bool

func run():
	is_target_reached = data["target_reached"]
	if is_target_reached:
		super.success()
	else:
		super.fail()
	
func start():
	is_target_reached = data["target_reached"]
	super.start()
