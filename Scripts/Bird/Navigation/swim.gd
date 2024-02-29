extends Task

class_name Swim

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Swim") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	await bird.animated_sprite.play_swimming_animation()
	if bird.animatated_spite.animation == "Swimming":
		super.success()
	else:
		super.fail()

func start()->void:
	super.start()
