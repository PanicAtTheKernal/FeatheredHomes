extends Task

class_name PlayAnimation

var bird: Bird

func _init(parent_bird: Bird, node_name: String="PlayAnimation") -> void:
	super(node_name)
	bird = parent_bird

func run() -> void:
	await bird.animatated_spite.play_eating_animation()
	await bird.animatated_spite.animation_group_finished
	# Wait until the eating animation is completed before moving on
	if bird.animatated_spite.finished != "eating":
		super.fail()
		return
	super.success()
	
func start() -> void:
	super.start()
