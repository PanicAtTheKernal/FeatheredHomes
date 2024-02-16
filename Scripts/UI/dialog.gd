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

func display(message: String, heading: String = "Notice:")->void:
	dialog.visible = true
	dialog_text.text = message
	heading_text.text = str("[b]",heading,"[/b]")

func increase_dialog()->void:
	(%Panel as Panel).custom_minimum_size.y = 800

func _on_ok_button_pressed()->void:
	(%Panel as Panel).custom_minimum_size.y = 420	
	dialog.visible = false
	get_tree().call_group("PlayerCamera", "turn_on_movement")
