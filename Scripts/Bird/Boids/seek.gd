extends Steering

class_name Seek
	

func calculate() -> Vector2:
	var to_target = (target - bird.global_position).normalized()
	var desired = to_target * bird.SPEED
	return desired - bird.velocity

func set_target(seek_target: Vector2)->void:
	bird.target = seek_target
