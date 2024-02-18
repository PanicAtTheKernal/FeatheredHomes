extends Task

class_name CheckIfSwimming

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CheckIfSwimming") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.current_tile == "Water" and not bird.target_reached:
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()
