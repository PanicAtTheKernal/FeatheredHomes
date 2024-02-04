extends Button

func _on_pressed()->void:
	get_tree().call_group("PlayerCamera", "zoom_in")

