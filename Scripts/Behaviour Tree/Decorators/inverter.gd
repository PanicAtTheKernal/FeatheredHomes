# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name Inverter

func run()->void:
	get_child(0).run()
	running()

func child_success()->void:
	fail()

func child_fail()->void:
	success()
