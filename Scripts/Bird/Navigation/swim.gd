extends Task

class_name Swim

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Swim") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.animation != "Swimming":
		bird.animated_sprite.play_swimming_animation()
	super.success()

func start()->void:
	super.start()
