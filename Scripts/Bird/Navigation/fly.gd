extends Task

class_name Fly

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Swim") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	bird.animatated_spite.update_state("Flying")
	# Wait for the take-off animation to finish
	await bird.animatated_spite.play_flying_animation()
	super.success()
	
func start()->void:
	super.start()

