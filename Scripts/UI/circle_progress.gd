extends TextureProgressBar


var current_value = 0

func _process(delta)->void:
	current_value = (current_value + 5) % 360
	radial_initial_angle = current_value

func hide_loading()->void:
	hide()

func show_loading()->void:
	show()
