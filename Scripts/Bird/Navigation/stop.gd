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
	var i = stop_condition.call()
	if stop_condition.call():
		#if bird.animatated_spite.animation == "Flight":
			#await bird.animatated_spite.play_landing_animation()
			#await bird.animatated_spite.animation_group_finished
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()
