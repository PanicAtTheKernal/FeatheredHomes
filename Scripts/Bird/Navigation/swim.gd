extends Task

class_name Swim

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Swim") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	bird.animatated_spite.update_state("Water")
	bird.animated_sprite.play_swimming_animation()
	super.success()
	
func start()->void:
	super.start()
