extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_line_edit_text_submitted(new_text):
	var invite_code = Database.config.get_value(Database.ENVIRONMENT_VARIABLES, "INVITE_CODE")
	if new_text == invite_code:
		hide()
	else:
		get_tree().call_group("Dialog","display","Invalid code")
