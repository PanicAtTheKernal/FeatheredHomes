extends CanvasLayer

@export
var bird_scene: PackedScene

@export
var world_rescources: WorldResources
@export
var player_cam: Camera2D
@export
var tile_map: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var bird = bird_scene.instantiate()
	var center_pos = player_cam.get_screen_center_position()
	bird.position = center_pos
	bird.tile_map = tile_map
	bird.world_resources = world_rescources
	
	get_parent().add_child(bird)
