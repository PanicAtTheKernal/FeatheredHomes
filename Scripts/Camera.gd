extends Node

class_name Camera

# Android camera variables
var plugin
var plugin_name = "GodotGetImage"
var options = {
	"image_height" : 200,
	"image_width" : 100,
	"keep_aspect" : true,
	"image_format" : "jpg"
}

var temp_node: TextureRect

func _ready():
	var os_name = OS.get_name()
	match os_name:
		"Android":
			setup_camera_andorid()

func _on_image_request_completed(image_buffers):
	var image = Image.new()
	var error = image.load_jpg_from_buffer(image_buffers.values()[0])

	if error != OK:
		get_tree().call_group("Dialog", "display", "Error loading the image")		
		
	Database.send_image_request(image)

func _on_error(e):
	get_tree().call_group("Dialog", "display", e)

func _on_permission_not_granted_by_user():
	plugin.resendPermission()

func take_picture():
	var os_name = OS.get_name()
	match os_name:
		"Android":
			take_picture_andorid()	
		"iOS":
			take_picture_ios()
		_:
			get_tree().call_group("Dialog", "display", ("Platform "+os_name+" is not supported"))

func take_picture_andorid():
	if plugin:
		plugin.getCameraImage()
	else:
		print(plugin_name, " plugin not loaded!")
	
func take_picture_ios():
	pass

func setup_camera_andorid():
	if Engine.has_singleton(plugin_name):
		plugin = Engine.get_singleton(plugin_name)
	else:
		get_tree().call_group("Dialog", "display", ("Could not load plugin: "+plugin_name))
	
	if plugin:
		plugin.connect("image_request_completed", _on_image_request_completed)
		plugin.connect("error", _on_error)
		plugin.connect("permission_not_granted_by_user", _on_permission_not_granted_by_user)
		plugin.setOptions(options)
