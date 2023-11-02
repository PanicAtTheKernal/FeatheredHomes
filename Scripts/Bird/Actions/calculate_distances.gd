extends Task

class_name CalculateDistances

var ground_agent: NavigationAgent2D
var flight_agent: NavigationAgent2D
var character_body: CharacterBody2D
var ground_cost: float
var flight_cost: float
var take_off_cost: float

@export
var mid_flight_calculations: bool = true

func run():
	if data["calculate_distances"] == false:
		if BirdHelperFunctions.character_at_target(character_body.global_position, data["target"]):
			super.success()
			return
		get_child(0).run()
		super.running()
		return
	
	# It won't build the path unless this function is called
	ground_agent.get_next_path_position()
	flight_agent.get_next_path_position()
	
	var ground_path = ground_agent.get_current_navigation_result().path
	var flight_path = flight_agent.get_current_navigation_result().path
	
	var ground_dist = BirdHelperFunctions.total_distance(ground_path)	
	var flight_dist = BirdHelperFunctions.total_distance(flight_path)
	
	var total_ground_energy_cost = BirdHelperFunctions.calculate_energy_cost(ground_dist, 0.0, ground_cost)
	var total_flight_energy_cost = BirdHelperFunctions.calculate_energy_cost(flight_dist, take_off_cost, flight_cost)
	
	data["ground_dist"] = ground_dist
	data["flight_dist"] = flight_dist
	data["total_ground_energy_cost"] = total_ground_energy_cost
	data["total_flight_energy_cost"] = total_flight_energy_cost
	data["calculate_distances"] = false

	get_child(0).run()
	# Waiting for the movement nodes to succeed will prevent this node from calculating mid_flight
	if mid_flight_calculations:
		super.success()
	else:
		super.running()
	
func child_success():
	super.success()

func start():
	ground_agent = self.data["ground_agent"]
	flight_agent = self.data["flight_agent"]
	character_body = self.data["character_body"]
	ground_cost = self.data["ground_cost"]
	flight_cost = self.data["flight_cost"]
	take_off_cost = self.data["take_off_cost"]
	super.start()
