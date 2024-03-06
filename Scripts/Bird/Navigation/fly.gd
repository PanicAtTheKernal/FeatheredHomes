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
	super.success()
	# Logger.print_debug(bird.animatated_spite.animation, logger_key)
	# if bird.animatated_spite.animation == "Flight":
	# 	super.success()
	# 	return
	# 	bird.animatated_spite.stop()
	# 	bird.animatated_spite.play_flying_animation()
	# if bird.animatated_spite.animation == "Take-off":
	# 	super.running()
		
func start()->void:
	super.start()

