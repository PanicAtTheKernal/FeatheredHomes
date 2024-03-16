extends Task

class_name Fly

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Fly") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.animation != "Flight":
		bird.animatated_spite.play_flying_animation()
		Logger.print_running(bird.scale, logger_key)
		bird.tween = create_tween()
		bird.tween.set_ease(Tween.EASE_OUT)
		bird.tween.set_trans(Tween.TRANS_QUINT)
		bird.tween.tween_property(bird, "scale", bird.scale+(Vector2(0.2,0.2)), 1)
		Logger.print_running(bird.scale, logger_key)
		bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished) 
		Logger.print_running("Running: Playing the flying animation", logger_key)
		super.running()
		return
	Logger.print_success("Success: The bird is flying", logger_key)
	super.success()
		
func start()->void:
	super.start()

