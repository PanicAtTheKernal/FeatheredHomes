extends Task

class_name ReachedTarget

var bird: Bird

func _init(parent_bird: Bird, node_name:="ReachedTarget") -> void:
	super(node_name)
	bird = parent_bird

func run():
	if BirdHelperFunctions.character_at_target(bird.global_position, bird.target) == false:
		super.fail()
		return
	bird.target_reached = false
	super.success()
	
func start():
	super.start()
