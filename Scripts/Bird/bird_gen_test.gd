extends Node2D


func _enter_tree():
	#var shader: ShaderMaterial = get_child(0).material
	#shader.set_shader_parameter("HEAD", preload("res://Assets/head.png"))
	pass

# Called when the node enters the scene tree for the first time.
#func _ready():
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
func _process(delta):
	if change:
		$AnimatedSprite2D.play("Take-off")
	else:
		$AnimatedSprite2D.play("Flight")	


func _on_animated_sprite_2d_animation_finished():
	change = false


func _on_animated_sprite_2d_animation_looped():
	$AnimatedSprite2D.play("Flight")	
