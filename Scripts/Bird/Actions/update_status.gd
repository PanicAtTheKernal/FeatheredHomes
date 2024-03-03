extends Task

class_name UpdateStatus

var bird: Bird
var status_label: String

func _init(parent_bird: Bird, new_status: String, node_name: String="UpdateStatus") -> void:
	super(node_name)
	bird = parent_bird
	status_label = new_status

func run() -> void:
	bird.info.status = status_label
	super.success()

func start() -> void:
	super.start()
