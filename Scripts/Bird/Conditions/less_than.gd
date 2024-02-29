extends Condition

class_name LessThan

func run() -> void:
	super.run()
	if value < condition:
		super.success()
	else:
		super.fail()
