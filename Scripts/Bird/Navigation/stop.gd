extends Task

# Stop the current animation if reached target
class_name Stop

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Stop") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.at_target() and bird.animatated_spite.animation == "Flight":
		await bird.animatated_spite.play_landing_animation()
		await bird.animatated_spite.animation_group_finished
	super.success()
	
func start()->void:
	super.start()
