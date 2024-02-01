extends Task

class_name CheckIfWalking

@export
var check_ground_type: CheckGroundType
var is_target_reached: bool

func run():
	is_target_reached = data["target_reached"]
	if check_ground_type.current_tile == "Ground" and not is_target_reached:
		super.success()
	else:
		super.fail()
	
func start():
	is_target_reached = data["target_reached"]
	super.start()
