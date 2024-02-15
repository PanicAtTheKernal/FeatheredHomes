extends Task

class_name CheckIfFlying

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CheckIfFlying") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.state == bird.States.AIR and not bird.target_reached:
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()