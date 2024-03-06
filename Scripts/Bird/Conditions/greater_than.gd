extends Condition

class_name GreaterThan

func run() -> void:
	super.run()
	if value > condition:
		Logger.print_success("Success", logger_key)
		super.success()
	else:
		Logger.print_fail("Fail", logger_key)
		super.fail()

