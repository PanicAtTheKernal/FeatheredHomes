extends TextureButton

@onready
var crosshair = $"./../Crosshair"
@onready
var dialog = $"./../Dialog"

func _on_pressed():
	CameraNode.take_picture(crosshair, dialog)
