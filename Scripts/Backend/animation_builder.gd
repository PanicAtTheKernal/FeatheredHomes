extends Node

class_name AnimationBuilder

var animation_template: Dictionary
var image_url: String
var image_name: String
var file_name: String
var sprite_width: float
var sprite_height: float

func _init(bird_animation: Dictionary, _image_url: String) -> void:
	animation_template = bird_animation["animation"]
	image_url = _image_url
	image_name = _create_image_name()
	file_name = _create_file_name()
	sprite_width = bird_animation["spriteWidth"]
	sprite_height = bird_animation["spriteHeight"]

func _create_image_name()->String:
	var image_name_index = image_url.rfind("BirdAssets")
	return image_url.substr(image_name_index).replace("BirdAssets/", "")	

func _create_file_name()->String:
	return image_name.split("/")[1]

func _download_image()->void:
	await Database.download_image(image_name, file_name)

func _load_image()->ImageTexture:
	var texture = Image.new()
	texture.load(BirdResourceManager.BIRD_DATA_PATH + file_name)
	var image: ImageTexture = ImageTexture.create_from_image(texture)
	return image
	
func _create_frames(image: ImageTexture)->Array[AtlasTexture]:
	var frames: Array[AtlasTexture] = []
	var height = image.get_height() as float
	var width = image.get_width() as float
	var num_frames = floor(width/sprite_width)
	for i in range(0, num_frames):
		var newFrame = AtlasTexture.new()
		newFrame.atlas = image
		newFrame.region = Rect2(sprite_width*i, 0, sprite_width, height)
		frames.push_back(newFrame)
	return frames

func _create_animations(frames: Array[AtlasTexture])->SpriteFrames:
	var animations = SpriteFrames.new()
	var animation_names = animation_template.keys()
	print(animation_names)
	for animation_name in animation_names:
		var animation_info = animation_template.get(animation_name)
		var animation_frames = animation_info["frames"]
		var fps = animation_info["fps"]
		var loop = animation_info["loop"]
		# Fix the error with "default" already existing on new spriteFrames
		if !animations.has_animation(animation_name):
			animations.add_animation(animation_name)
		animations.set_animation_loop(animation_name, loop)
		animations.set_animation_speed(animation_name, fps)
		for animation_frame in animation_frames:
			animations.add_frame(animation_name, frames[animation_frame])
	return animations

func build()->SpriteFrames:
	await _download_image()
	var image = _load_image()
	var frames = _create_frames(image)
	var animations: SpriteFrames = _create_animations(frames)
	return animations
