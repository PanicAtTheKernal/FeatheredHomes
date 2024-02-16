extends Control

@onready
var line_edit: LineEdit = %LineEdit

func show_search()->void:
	show()
	line_edit.clear()
	get_tree().call_group("PlayerCamera", "turn_off_movement")

func _validate_input(input: String)->bool:
	var validator_regex = RegEx.new()
	validator_regex.compile("^[A-Za-z ]+$")
	return validator_regex.search(input) != null
	
func _on_ok_button_pressed()->void:
	hide()
	var input = line_edit.text.strip_edges()
	if _validate_input(input):
		BirdResourceManager.find_bird(input)
		get_tree().call_group("LoadingSearchButton", "show_loading")
		get_tree().call_group("PlayerCamera", "turn_on_movement")
	else:
		get_tree().call_group("Dialog", "display", "Please enter a valid name without numbers or special characters")


func _on_cancel_button_pressed() -> void:
	hide()
	get_tree().call_group("PlayerCamera", "turn_on_movement")
