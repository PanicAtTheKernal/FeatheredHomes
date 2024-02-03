extends Button

func _on_pressed()->void:
	Camera.take_picture()

func show_loading()->void:
	hide()

func hide_loading()->void:
	show()
