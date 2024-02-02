extends Button

@onready
var bird_history_ui = %BirdHistory

func _on_pressed():
	bird_history_ui.show()
