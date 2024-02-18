extends CharacterBody2D

class_name Bird

enum States {
	GROUND,
	AIR,
	MIGRATING
}

const SPEED = 40**2 
const ARRIVAL_THRESHOLD = 5.0
const CALORIES_BURNED = 10

@export
var nav_agent: NavigationAgent2D
@export
var animatated_spite: BirdAnimation
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
var direction: Vector2
var next_path_position: Vector2
var current_stamina: float
var distance_to_target: float
var target_reached: bool = false
var is_distance_calculated: bool = false
var is_standing_on_branch: bool = false
var state: States = States.AIR
var current_tile: String
var physics_delta: float

signal change_state(new_state: String, should_flip_h: bool)

func _ready():
	animatated_spite.sprite_frames = species.animations
	animatated_spite.animation_finished.connect(_on_animation_finished)
	current_stamina = species.stamina
	# TODO Look into removing this
	$NavigationTimer.autostart = true
	# Start the navaiagation timer at differnet times for each bird
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	$NavigationTimer.start()

func _physics_process(delta: float)->void:
	physics_delta = delta

func update_target(new_target: Vector2):
	target = new_target
	if nav_agent.target_position == target:
		return
	nav_agent.target_position = target
	nav_agent.get_next_path_position()
	await nav_agent.path_changed
	is_distance_calculated = false 

## Function to make sure the bird is at the target
func at_target()->bool:
	# Round the number to the nearest whole number because float precision was causing accuracy issues 
	var character_pos_rounded = round(global_position)
	var target_rounded = round(target)
	var test = (character_pos_rounded - target_rounded).length()
	if test < ARRIVAL_THRESHOLD:
		return true
	else:
		return false

func burn_caloires():
	var movement_cost = species.ground_cost if state == States.GROUND else species.flight_cost
	var amount = CALORIES_BURNED * species.size + movement_cost
	current_stamina = clamp(current_stamina - amount, 0, species.max_stamina)
	info.species.stamina = current_stamina
	# Death State
	if current_stamina == 0:
		info.status = BirdInfo.StatusTypes.DEAD
		queue_free()
	
func add_caloires(amount:float):
	current_stamina = clamp(current_stamina + amount, 0, species.max_stamina)
	info.species.stamina = current_stamina	
	
func _on_animation_finished()->void:
	# Enable the AI after the animation is finished playing
	behavioural_tree.set_physics_process(true)
		

func _on_button_pressed():
	get_tree().call_group("BirdStat", "show")	
	get_tree().call_group("BirdStat", "load_new_bird", info)


func _on_calorie_timer_timeout() -> void:
	burn_caloires()
