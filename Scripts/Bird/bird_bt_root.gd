extends Task

class_name BirdBehaviouralTree

func _ready():
	var parent = self.get_parent()
	self.data = {
		"tile_map": parent.tile_map,
		"ground_agent": parent.find_child("GroundAgent"),
		"flight_agent": parent.find_child("FlightAgent"),
		"target": BirdHelperFunctions.calculate_tile_position(parent.target),
		"target_reached": false,
		"character_body": parent,
		"world_resources": parent.world_resources,
		"range": parent.bird_range,
		"take_off_cost": parent.take_off_cost, 
		"flight_cost": parent.flight_cost,
		"ground_cost": parent.ground_cost,
		"stamina": parent.stamina,
		"max_stamina": parent.max_stamina,
		"is_flying": false,
		"change_state": parent.change_state,
		"current_ground": "",
		"calculate_distances": true
	}
	super.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.data["delta"] = delta
	run()


func _on_navigation_update_timeout():
	# If flight_agent is not set then none of the data is set
	if self.data["flight_agent"] == null:
		return
	self.data["flight_agent"].set_navigation_map(data["tile_map"].get_navigation_map(1))
	self.data["flight_agent"].target_position = data["target"]
	self.data["ground_agent"].target_position = data["target"]
	self.data["flight_agent"].get_next_path_position()
	self.data["ground_agent"].get_next_path_position()
	self.data["calculate_distances"] = true

func run():
	for child in get_children():
		child.run()


func _on_calorie_timer_timeout():
	# TODO add a moving check for ground
	if data["is_flying"]: 
		BirdHelperFunctions.burn_caloires(data["flight_cost"], data)
	else:
		BirdHelperFunctions.burn_caloires(data["ground_cost"], data)
	
	if data["stamina"] == 0:
		# Death State
		self.get_parent().queue_free()
