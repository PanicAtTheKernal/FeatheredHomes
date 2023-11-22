extends TextureProgressBar


var current_value = 0

func _process(delta):
	current_value = (current_value + 5) % 360
	radial_initial_angle = current_value

