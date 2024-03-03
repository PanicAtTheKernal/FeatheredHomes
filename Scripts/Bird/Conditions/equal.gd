extends Condition

class_name Equal

func run() -> void:
	super.run()
	if value == condition:
		super.success()
	else:
		super.fail()
