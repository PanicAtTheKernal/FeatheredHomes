extends TextureButton

func _on_pressed():
	CameraNode.take_picture()

func show_loading():
	hide()

func hide_loading():
	show()
