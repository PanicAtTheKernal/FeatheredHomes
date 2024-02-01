extends Task

class_name CheckIfMovingOnGround

@export
var calculate_distance: CalculateDistance

func run():
	if calculate_distance.state == calculate_distance.States.ground:
		super.success()
		return
	else:
		super.fail()
	
func start():
	super.start()
