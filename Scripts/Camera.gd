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
var dialog: Dialog


func _ready():
	setup_camera_andorid()

func _on_image_request_completed(image_buffers):
	for image_buffer in image_buffers.values():
		var image = Image.new()
		var error = image.load_jpg_from_buffer(image_buffer)
	
		if error != OK:
			dialog.display("Error loading an image")
			
		var image_texture = ImageTexture.create_from_image(image)
		if image_texture == null:
			dialog.display("Error processing image")
		temp_node.texture = image_texture

func _on_error(e):
	dialog.show_dialog(e)

func _on_permission_not_granted_by_user():
	plugin.resendPermission()

func take_picture(temp_node, dialog):
	self.temp_node = temp_node
	self.temp_node.texture = null
	self.dialog = dialog
	var os_name = OS.get_name()
	match os_name:
		"Android":
			take_picture_andorid()	
		"iOS":
			take_picture_ios()
		_:
			dialog.display(("Platform "+os_name+" is not supported"))

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
		print("Could not load plugin: ", plugin_name)
	
	if plugin:
		plugin.connect("image_request_completed", _on_image_request_completed)
		plugin.connect("error", _on_error)
		plugin.connect("permission_not_granted_by_user", _on_permission_not_granted_by_user)
		plugin.setOptions(options)
