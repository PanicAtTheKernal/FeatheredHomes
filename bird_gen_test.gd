extends Node2D


@onready 
var head_start: Marker2D = $HeadStart
@onready
var head_end: Marker2D = $HeadEnd

# Called when the node enters the scene tree for the first time.
func _ready():
	var halfway_x = (head_start.position.x + head_end.position.x)/2
	var halfway_y = (head_start.position.y + head_end.position.y)/2
	var halfway_point = Vector2(halfway_x, halfway_y)
	var distance = head_start.position.distance_to(head_end.position)
	var new_sprite = Sprite2D.new()
	add_child(new_sprite)	
	var image = load("res://Assets/head2.png")
	new_sprite.texture = image
	#new_sprite.position = Vector2(halfway_point.x, halfway_point.y-(distance)/2)
	#new_sprite.scale = Vector2(0.5, 0.5)
	
	print(halfway_point)
	print_tree()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
