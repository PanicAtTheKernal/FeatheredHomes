extends Task

class_name BirdBehaviouralTree

func _init() -> void:
	super("Root")

func _ready():
	super.start()

# Start running the tree
func _physics_process(_delta):
	run()

func run()->void:
	for child in get_children():
		child.run()
