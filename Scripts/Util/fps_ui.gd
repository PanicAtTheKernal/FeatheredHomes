extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	text = str("[color=Green]",
		"FPS: ",Performance.get_monitor(Performance.TIME_FPS),"\n",
		"Physics_process: ",Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),"\n",
		"Navigation_process: ",Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),"\n",
		"Node Count: ",Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"\n",		
		"[/color]")
