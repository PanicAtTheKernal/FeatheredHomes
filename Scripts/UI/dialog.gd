extends Control

class_name Dialog

@onready 
var dialog_text : RichTextLabel = %Text
@onready
var heading_text : Label = %Notice
@onready
var dialog: Control = $"."

func _ready()->void:
	dialog.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta)->void:
	pass

func display(message: String, heading: String = "Notice:")->void:
	dialog.visible = true
	dialog_text.text = message
	heading_text.text = heading

func _on_ok_button_pressed():
	dialog.visible = false
	get_tree().call_group("PlayerCamera", "turn_on_movement")
