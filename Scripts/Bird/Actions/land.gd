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
		bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished)
	super.success()

func start() -> void:
	super.start()
