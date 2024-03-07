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
		bird.behavioural_tree.wait_for_function(bird.update_target.bind(result))
	Logger.print_success("Success: Bird is flying to "+str(result), logger_key)
	super.success()

func start() -> void:
	super.start()
