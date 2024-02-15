extends Task

class_name CheckIfReachedTarget

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CheckIfReachedTarget") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.at_target():
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()
