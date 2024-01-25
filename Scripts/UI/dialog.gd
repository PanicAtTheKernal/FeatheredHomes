extends Control

class_name Dialog

@onready 
var dialog_text : Label = $NinePatchRect/Text
@onready
var dialog: Control = $"."

func _ready():
	dialog.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display(message: String):
	dialog.visible = true
	dialog_text.text = message

func _on_ok_pressed():
	dialog.visible = false
