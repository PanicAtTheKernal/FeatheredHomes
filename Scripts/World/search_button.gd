extends Button

func _on_pressed() -> void:
	if Database.is_connected_to_db:
		get_tree().call_group("Search", "show_search")
	else:
		get_tree().call_group("Selection", "show_search")

func show_loading()->void:
	hide()

func hide_loading()->void:
	show()
