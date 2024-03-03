extends Task

class_name BirdBehaviouralTree

var cycle: int = 0
var run_tree: bool

func _init() -> void:
	super("Root")

func _ready():
	super.start()
	run_tree = true

# Start running the tree
func _physics_process(_delta):
	if true:
		await run()
		Logger.print_debug("cycle: " + str(cycle), logger_key)
		cycle += 1
		run_tree = false


func run()->void:
	for child in get_children():
		await child.run()


func _on_navigation_timer_timeout() -> void:
	run_tree = true
