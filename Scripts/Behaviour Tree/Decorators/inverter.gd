# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name Inverter

func run()->void:
	var child = get_child(0)
	Logger.print_debug("RUNNING ("+str(child.logger_key.obj)+")", logger_key)
	child.run()
	running()

func child_success()->void:
	fail()

func child_fail()->void:
	success()
