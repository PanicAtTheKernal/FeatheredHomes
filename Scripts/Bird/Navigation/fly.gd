extends Task

class_name Fly

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Swim") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	await bird.animatated_spite.play_flying_animation()
	if bird.animatated_spite.animation == "Flight":
		super.success()
	else:
		super.fail()
		
func start()->void:
	super.start()

