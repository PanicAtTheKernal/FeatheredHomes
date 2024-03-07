extends Task

# Stop the current animation if reached target
class_name Stop

var bird: Bird
var stop_condition: Callable

func _init(parent_bird: Bird, condition: Callable, node_name:String="Stop") -> void:
	super(node_name)
	bird = parent_bird
	stop_condition = condition


func run()->void:
	if stop_condition.call():
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()
