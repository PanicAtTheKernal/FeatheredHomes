class_name Camera

var plugin
var plugin_name = "GodotGetImage"
var temp_node: TextureRect

func _ready():
	if Engine.has_singleton(plugin_name):
		plugin = Engine.get_singleton(plugin_name)
	else:
		print("Could not load plugin: ", plugin_name)

	if plugin:
		plugin.connect("image_request_completed", _on_image_request_completed)
		plugin.connect("error", _on_error)
		plugin.connect("permission_not_granted_by_user", _on_permission_not_granted_by_user)

func _on_image_request_completed(image_buffers):
	var image = Image.new()
	var error = image.load_png_from_buffer(image_buffers.values()[0])
	
	if error == OK:
		var image_texture = ImageTexture.new().create_from_image(image)
		temp_node.texture = image_texture

func _on_error():
	pass

func _on_permission_not_granted_by_user():
	pass

func take_picture(temp_node):
	self.temp_node = temp_node
	var os_name = OS.get_name()
	match os_name:
		"Android":
			take_picture_andorid()	
		"iOS":
			take_picture_ios()

func take_picture_andorid():
	pass
	
func take_picture_ios():
	pass
