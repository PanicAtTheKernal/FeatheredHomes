extends Task

class_name ReachedTarget

var bird: Bird

func _init(parent_bird: Bird, node_name:String="ReachedTarget") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		super.fail()
		return
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
