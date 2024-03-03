# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name UntilSuccess

func run():
	get_child(0).run()
	running()

func child_success():
	success()

# Ignore child failure
func child_fail():
	pass
