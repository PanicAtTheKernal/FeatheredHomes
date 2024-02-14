extends Task

class_name CheckStamina

# TODO Randomise this
var threshold: float = 0.5

var bird: Bird

func _init(parent_bird: Bird, node_name: String="CheckStamina") -> void:
	super(node_name)
	bird = parent_bird

func run():
	if bird.current_stamina > (bird.species.max_stamina * threshold):
		super.fail()
	else:
		super.success()

func start():
	pass
