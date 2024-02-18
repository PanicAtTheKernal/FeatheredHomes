# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name Selector

var current_child = 0

func run()->void:
	get_child(current_child).run()
	running()

func child_success():
	current_child = 0
	success()

func child_fail():
	current_child += 1
	if current_child >= get_child_count():
		current_child = 0
		fail()

func cancel():
	current_child = 0
	super.cancel()

func start()->void:
	current_child = 0
	super.start()
