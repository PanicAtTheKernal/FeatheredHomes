extends Task

class_name Walk

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Walk") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	# await bird.animatated_spite.update_state("Ground")
	await bird.animatated_spite.play_walking_animation()
	if bird.animatated_spite.animation == "Walking":
		super.success()
	else:
		super.fail()
	
func start()->void:
	super.start()
