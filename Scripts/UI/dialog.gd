extends Control

class_name Dialog

@onready 
var dialog_text : RichTextLabel = %Text
@onready
var heading_text : RichTextLabel = %Notice
@onready
var dialog: Control = $"."

func _ready()->void:
	dialog.visible = false

func display(message: String, heading: String = "Notice:", fit_content: bool = true)->void:
	dialog.visible = true
	dialog_text.text = message
	dialog_text.fit_content = fit_content
	heading_text.text = str("[b]",heading,"[/b]")

func increase_dialog()->void:
	(%Panel as PanelContainer).custom_minimum_size.y = 800

func _on_ok_button_pressed()->void:
	(%Panel as PanelContainer).custom_minimum_size.y = 200	
	dialog.visible = false
	get_tree().call_group("PlayerCamera", "turn_on_movement")
