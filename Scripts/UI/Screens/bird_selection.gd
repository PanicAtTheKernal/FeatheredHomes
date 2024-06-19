extends Control

@onready
var panel = %Panel

func _process(_delta: float) -> void:
	var window = get_window()
	if window.size.x > Startup.NON_MOBLIE_SIZE:
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.custom_minimum_size.x = 960
	else:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = 0

func show_search()->void:
	show()
	get_tree().call_group("PlayerCamera", "turn_off_movement")
