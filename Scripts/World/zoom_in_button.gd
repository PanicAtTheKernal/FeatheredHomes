extends TextureButton


func _on_pressed():
	get_tree().call_group("PlayerCamera", "zoom_in")

