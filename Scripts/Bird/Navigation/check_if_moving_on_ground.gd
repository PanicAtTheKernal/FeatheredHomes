extends Task

class_name CheckIfMovingOnGround

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CheckIfMovingOnGround") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.state == bird.States.GROUND:
		super.success()
		return
	else:
		super.fail()
	
func start()->void:
	super.start()
