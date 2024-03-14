extends Task

class_name Land

var bird: Bird


# Structured as which bird property must pass the condition set by the bird
func _init(parent_bird: Bird, node_name: String="Condition") -> void:
	super(node_name)
	bird = parent_bird

func run() -> void:
	if bird.animatated_spite.animation == "Flight":
		bird.animatated_spite.play_landing_animation()
		bird.tween = create_tween()
		bird.tween.set_ease(Tween.EASE_OUT)
		bird.tween.set_trans(Tween.TRANS_QUINT)
		bird.tween.tween_property(bird, "scale", bird.scale-(Vector2(0.2,0.2)), 1)
		bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished)
		Logger.print_running("Running: Playing the landing animation", logger_key)
		super.running()
	Logger.print_success("Success: The bird has landed", logger_key)
	super.success()

func start() -> void:
	super.start()
