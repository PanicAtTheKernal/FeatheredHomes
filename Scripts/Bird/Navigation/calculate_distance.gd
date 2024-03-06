extends Task

## Not needed anymore
## @deprecated
##

class_name CalculateDistance

var bird: Bird

func _init(parent_bird: Bird, node_name:String="CalculateDistance") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	# Skip calculating a new distance if the every frame, it should be done every second for 
	# preformance reasons 
	if bird.is_distance_calculated:
		super.success()
		return
	bird.distance_to_target = bird.global_position.distance_to(bird.target)/WorldResources.TILE_SIZE
	Logger.print_debug(str("[Distance] ",bird.distance_to_target), logger_key)
	if (bird.distance_to_target < bird.species.ground_max_distance) and (not bird.is_standing_on_branch):
		set_target_for_ground()
	elif bird.distance_to_target > bird.species.flight_max_distance:
		# Migration is a seperate behaviour, if the distance requires it, 
		# then this movement sequence will fail
		set_target_for_migration()
	else:
		set_target_for_air()
	bird.is_distance_calculated = true

func start()->void:
	#navigation_data.navigation_timer.timeout.connect(_on_navigation_timer_timeout)
	super.start()

#func _on_navigation_timer_timeout():
	## Check if the current target on the agent is the same as the stored target
	#if nav_agent.target_position == target:
		#return
		#
	#nav_agent.target_position = target
	#nav_agent.get_next_path_position()
	#set_physics_process(false)
	#is_distance_calculated = false


func set_target_for_ground()->void:
	Logger.print_debug("Walking/Swimming to target", logger_key)
	bird.state = bird.States.GROUND
	bird.nav_agent.set_navigation_layer_value(1, true)
	bird.set_collision_mask_value(1, false)
	if bird.species.can_fly:
		bird.nav_agent.set_navigation_layer_value(2, true)
		bird.set_collision_mask_value(2, false)
	else:
		bird.nav_agent.set_navigation_layer_value(2, false)
		bird.set_collision_mask_value(2, true)
	super.success()
	
func set_target_for_air()->void:
	Logger.print_debug("Flying to target", logger_key)
	bird.state = bird.States.AIR
	bird.nav_agent.set_navigation_layer_value(1, true)
	bird.set_collision_mask_value(1, true)
	bird.nav_agent.set_navigation_layer_value(2, true)
	bird.set_collision_mask_value(2, true)
	super.success()

# If the distance require migration then a different behaviour should deal with it
func set_target_for_migration()->void:
	Logger.print_debug("Migrating to target", logger_key)
	bird.state = bird.States.MIGRATING
	super.fail()
