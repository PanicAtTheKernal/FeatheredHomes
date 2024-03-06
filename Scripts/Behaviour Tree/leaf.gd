# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name Leaf

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Leaf") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	bird.behavioural_tree.pause_execution(3)
	Logger.print_success("Success:", logger_key)
	super.success()
