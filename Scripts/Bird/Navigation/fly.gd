extends Task

class_name Fly

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Fly") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.animation != "Flight":
		bird.animatated_spite.play_flying_animation()
		bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished) 
		Logger.print_running("Running: Playing the flying animation", logger_key)
		super.running()
		return
	Logger.print_success("Success: The bird is flying", logger_key)
	super.success()
		
func start()->void:
	super.start()

