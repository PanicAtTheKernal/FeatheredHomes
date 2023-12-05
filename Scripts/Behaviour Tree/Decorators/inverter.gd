# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name Inverter

func run():
	get_child(0).run()
	running()

func child_success():
	fail()

func child_fail():
	success()
