extends Task

class_name CalculateDistance

enum States {
	ground,
	air,
	migrating
}

var target: Vector2
@export
var distance: float = 0.0
@export_category("BirdNodes")
@export
var navigation_data: NavigationData
var nav_agent: NavigationAgent2D
var character_body: CharacterBody2D
@export_category("BirdSpeciesInformation")
@export
var bird_species_info: BirdSpecies
@export
var is_standing_on_branch: bool = false
@export
var state: States = States.air

var is_distance_calculated: bool = false

func run():
	# Skip calculating a new distance if the every frame, it should be done every second for 
	# preformance reasons 
	if is_distance_calculated:
		super.success()
		return
	
	# TODO remove hardcoding, 16.0 is the tile size, goal is to get the tile distance
	target = data["target"]
	distance = character_body.global_position.distance_to(target)/16.0
	print("Distance: " + str(distance))
	
	if (distance < bird_species_info.bird_ground_max_distance) and (not is_standing_on_branch):
		set_target_for_ground()
	elif distance > bird_species_info.bird_flight_max_distance:
		# Migration is a seperate behaviour, if the distance requires it, 
		# then this movement sequence will fail
		set_target_for_migration()
	else:
		set_target_for_air()
	
	is_distance_calculated = true

func start():
	character_body = navigation_data.character_body
	nav_agent = navigation_data.nav_agent
	bird_species_info = navigation_data.bird_species_info
	navigation_data.animated_sprite.animation_finished.connect(_on_animation_finished)
	target = data["target"]
	#navigation_data.navigation_timer.timeout.connect(_on_navigation_timer_timeout)
	super.start()

func _on_animation_finished():
	# Enable the AI after the animation is finished playing
	set_physics_process(true)

#func _on_navigation_timer_timeout():
	## Check if the current target on the agent is the same as the stored target
	#if nav_agent.target_position == target:
		#return
		#
	#nav_agent.target_position = target
	#nav_agent.get_next_path_position()
	#set_physics_process(false)
	#is_distance_calculated = false

func update_target(new_target: Vector2):
	# Update all the navigation nodes with the new target
	data["target"] = new_target
	target = data["target"]
	if nav_agent.target_position == target:
		return
		
	nav_agent.target_position = target
	nav_agent.get_next_path_position()
	set_physics_process(false)
	is_distance_calculated = false

func set_target_for_ground():
	print("On Ground")
	state = States.ground
	nav_agent.set_navigation_layer_value(1, true)
	character_body.set_collision_mask_value(1, false)
	if bird_species_info.can_bird_swim:
		nav_agent.set_navigation_layer_value(2, true)
		character_body.set_collision_mask_value(2, false)
	else:
		nav_agent.set_navigation_layer_value(2, false)
		character_body.set_collision_mask_value(2, true)
	super.success()
	
func set_target_for_air():
	print("On Air")
	state = States.air
	nav_agent.set_navigation_layer_value(1, true)
	character_body.set_collision_mask_value(1, true)
	nav_agent.set_navigation_layer_value(2, true)
	character_body.set_collision_mask_value(2, true)
	super.success()

# If the distance require migration then a different behaviour should deal with it
func set_target_for_migration():
	print("On Migration")
	state = States.migrating
	super.fail()
