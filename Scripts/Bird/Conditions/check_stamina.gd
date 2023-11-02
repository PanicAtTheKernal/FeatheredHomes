extends Task

class_name CheckStamina

func run():
	var stamina = data["stamina"]
	var max_stamina = data["max_stamina"]
	# TODO Move to bird.gd
	var threshold = 0.5
	if stamina > max_stamina * threshold:
		super.fail()
	else:
		super.success()

func start():
	pass
