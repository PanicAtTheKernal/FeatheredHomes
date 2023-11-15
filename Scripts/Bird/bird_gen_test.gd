extends Node2D


func _enter_tree():
	#var shader: ShaderMaterial = get_child(0).material
	#shader.set_shader_parameter("HEAD", preload("res://Assets/head.png"))
	pass

# Called when the node enters the scene tree for the first time.
func _ready():

	var animationTemplateResult = await Supabase.database.query(animationTemplate).completed
	var animatinoTemplateDict = animationTemplateResult.data[0]["BirdShapeAnimationTemplate"]
#	var storageResult: StorageTask = await Supabase.storage.from("BirdAssets").download("Chickadees/eurasian-blue-tit.png", "res://Assets/Download/eurasian-blue-tit.png").completed
	#print(result)
	print(animatinoTemplateDict)
	var texture = Image.load_from_file("res://Assets/Download/eurasian-blue-tit.png")
	var image: ImageTexture = ImageTexture.create_from_image(texture)
	var height = image.get_height()
	var width = image.get_width()
	var size = height
	# Each frame is equal in size and the sprite sheet is in a 1x? configuration therefore to get 
	# the amount of frame is to divide the width by the height
	var amount_of_frames = width/height
	var frames: Array[AtlasTexture] = []
	for i in range(0, amount_of_frames):
		var newFrame = AtlasTexture.new()
		newFrame.atlas = image
		newFrame.region = Rect2(size*i, 0, size, size)
		frames.push_back(newFrame)
		
	var sprite_frames = SpriteFrames.new()
	var animations = animatinoTemplateDict["animation"]
	var animation_names = animations.keys()
	print(animation_names)
	for animation_name in animation_names:
		var animation_info = animations.get(animation_name)
		var animation_frames = animation_info["frames"]
		var fps = animation_info["fps"]
		var loop = animation_info["loop"]
		sprite_frames.add_animation(animation_name)
		sprite_frames.set_animation_loop(animation_name, loop)
		sprite_frames.set_animation_speed(animation_name, fps)
		for animation_frame in animation_frames:
			sprite_frames.add_frame(animation_name, frames[animation_frame])
	ResourceSaver.save(sprite_frames, "res://Assets/eurasian-blue-tit.tres")
		
	
	
	print(amount_of_frames)
		
	$Sprite2D.texture = frames[1]	


	
#	var halfway_x = (head_start.position.x + head_end.position.x)/2
#	var halfway_y = (head_start.position.y + head_end.position.y)/2
#	var halfway_point = Vector2(halfway_x, halfway_y)
#	var distance = head_start.position.distance_to(head_end.position)
#	var new_sprite = Sprite2D.new()
#	var tail_sprite = Sprite2D.new()
#	add_child(new_sprite)	
#	var image = load("res://Assets/head2.png")
#	var tail = load("res://Assets/l0_sprite_2.png")
#	new_sprite.texture = image
#	new_sprite.scale = $Sprite2D.scale
#	new_sprite.position = $Sprite2D.position
#	#new_sprite.position = Vector2(halfway_point.x, halfway_point.y-(distance)/2)
#	#new_sprite.scale = Vector2(0.5, 0.5)
#	
#	tail_sprite.texture = tail
#	tail_sprite.scale = $Sprite2D.scale + (tail_sprite.scale * 0.2)
#	tail_sprite.position = body_sprite.position + (tail_sprite.position * 0.2) 
#	
#	add_child(tail_sprite)
#	print(halfway_point)
#	print_tree()

var change = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if change:
		$AnimatedSprite2D.play("Take-off")
	else:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("Flight")	


func _on_animated_sprite_2d_animation_finished():
	change = false


func _on_animated_sprite_2d_animation_looped():
	$AnimatedSprite2D.play("Flight")	
