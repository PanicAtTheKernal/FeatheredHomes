extends Node2D

@export
var bird_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var bird = bird_scene.instantiate()
	var center_pos = $PlayerCam.get_screen_center_position()
	bird.position = center_pos
	bird.tile_map = $TileMap
	bird.world_resources = $WorldResources
	
	add_child(bird)
