extends CharacterBody2D

class_name Bird

@export
var nav_agent: NavigationAgent2D
@export
var animatated_spite: AnimatedSprite2D
@export
var behavioural_tree: BirdBehaviouralTree

@export
var tile_map: TileMap
@export
var species: BirdSpecies
@export
var world_resources: WorldResources
@export
var info: BirdInfo

var id: int
var target: Vector2
var target_reached: bool = false
var is_distance_calculated: bool = false
var current_stamina: float

func _ready():
	animatated_spite.sprite_frames = species.animations
	current_stamina = species.stamina
	$NavigationTimer.autostart = true
	# Start the navaiagation timer at differnet times for each bird
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	$NavigationTimer.start()

func _physics_process(_delta: float)->void:
	pass

func traits():
	get_tree().call_group("Dialog", "display", "test")

func update_target(new_target: Vector2):
	target = new_target
	if nav_agent.target_position == target:
		return
	nav_agent.target_position = target
	nav_agent.get_next_path_position()
	behavioural_tree.set_physics_process(false)
	is_distance_calculated = false 

func _on_button_pressed():
	get_tree().call_group("BirdStat", "show")	
	get_tree().call_group("BirdStat", "load_new_bird", info)
