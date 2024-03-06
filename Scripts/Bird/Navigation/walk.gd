extends Task

class_name Walk

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Walk") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.animation != "Walking":
		bird.animatated_spite.play_walking_animation()
	super.success()
	
func start()->void:
	super.start()
