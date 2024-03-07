extends Button

@onready 
var settings: Control = %Settings

func _on_pressed():
	settings.show()
