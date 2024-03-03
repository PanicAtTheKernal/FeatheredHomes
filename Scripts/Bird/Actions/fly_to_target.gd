extends Task

class_name FlyToTarget

var bird: Bird
var target: Callable

func _init(parent_bird: Bird, world_cords: Callable, node_name: String="FlyToTarget") -> void:
	super(node_name)
	bird = parent_bird
	target = world_cords

func run() -> void:
	var result = target.call()
	if result != null:
		await bird.update_target(result)
	super.success()

func start() -> void:
	super.start()
