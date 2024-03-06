extends Task

class_name PlayAnimation

var bird: Bird

func _init(parent_bird: Bird, node_name: String="PlayAnimation") -> void:
	super(node_name)
	bird = parent_bird

func run() -> void:
	bird.animatated_spite.play_eating_animation()
	bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished) 
	super.success()
	
func start() -> void:
	super.start()
