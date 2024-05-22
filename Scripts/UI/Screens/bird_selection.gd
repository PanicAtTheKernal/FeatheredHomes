extends Control


func show_search()->void:
	show()
	get_tree().call_group("PlayerCamera", "turn_off_movement")
