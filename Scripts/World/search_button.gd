extends Button

func _on_pressed() -> void:
	get_tree().call_group("Search", "show_search")

func show_loading()->void:
	hide()

func hide_loading()->void:
	show()
