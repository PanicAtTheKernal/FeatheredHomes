extends Task

class_name CheckIfMovingOnAir

@export
var calculate_distance: CalculateDistance
var is_target_reached: bool

func run():
	is_target_reached = data["target_reached"]
	if calculate_distance.state == calculate_distance.States.air and not is_target_reached:
		super.success()
	else:
		super.fail()
	
func start():
	is_target_reached = data["target_reached"]
	super.start()
