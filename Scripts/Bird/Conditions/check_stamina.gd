extends Task

class_name CheckStamina

var threshold: float = 0.5

func run():
	var stamina = data["stamina"]
	var max_stamina = data["max_stamina"]
	# TODO Move threshold to bird species info
	if stamina > max_stamina * threshold:
		super.fail()
	else:
		super.success()

func start():
	pass
