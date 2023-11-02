extends Sprite2D

func _on_bird_change_state(new_state: String):
	if new_state == "Ground":
		modulate = Color(0, 0, 255)
	elif new_state == "Water":
		modulate = Color(255, 0, 0)
	elif new_state == "Flying":
		modulate = Color(0, 255, 0)
