extends Control

class_name Dialog

const NON_MOBLIE_SIZE = 1080

@onready 
var dialog_text : RichTextLabel = %Text
@onready
var heading_text : RichTextLabel = %Notice
@onready
var dialog: Control = $"."
@onready
var panel: PanelContainer = %Panel

func _ready()->void:
	dialog.visible = false

func _process(delta: float) -> void:
	var window = get_window()
	if window.size.x > NON_MOBLIE_SIZE:
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.custom_minimum_size.x = 960
	else:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = 0

func display(message: String, heading: String = "Notice:", fit_content: bool = true)->void:
	dialog.visible = true
	dialog_text.text = message
	dialog_text.fit_content = fit_content
	heading_text.text = str("[b]",heading,"[/b]")

func increase_dialog()->void:
	panel.custom_minimum_size.y = 800

func _on_ok_button_pressed()->void:
	panel.custom_minimum_size.y = 200	
	dialog.visible = false
	get_tree().call_group("PlayerCamera", "turn_on_movement")
