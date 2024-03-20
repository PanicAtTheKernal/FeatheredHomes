# Code based from https://gdscript.com/solutions/godot-behaviour-tree/

extends Task

class_name RandomSelector

var sequence
var idx = 0

func set_sequence():
	idx = 0
	sequence = range(get_child_count())
	sequence.shuffle()

func run():
	var child = get_child(sequence[idx])
	Logger.print_debug("RUNNING ("+str(child.logger_key.obj)+")", logger_key)
	child.run()
	running()

func child_success():
	set_sequence()
	success()

func child_fail():
	idx += 1
	if idx >= sequence.size():
		set_sequence()
		fail()

func cancel():
	set_sequence()
	super.cancel()

func start():
	set_sequence()
	super.start()
