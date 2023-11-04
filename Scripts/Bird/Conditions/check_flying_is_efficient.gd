extends Task

class_name CheckIfFlyingIsEfficient

var character_body: CharacterBody2D
var flight_agent: NavigationAgent2D

func run():
	var flight_cost:float = data["total_flight_energy_cost"]
	var ground_cost:float = data["total_ground_energy_cost"]
	
	if flight_cost == null:
		printerr("calculate distances node is missing")
	
	if not flight_agent.is_target_reachable() or flight_agent.get_current_navigation_result().path == PackedVector2Array([]):
		super.fail()
		return
	
	if flight_cost > ground_cost:
		super.fail()
	
	data["preferred_agent"] = "flight"
	if data["is_flying"] == false:
		BirdHelperFunctions.burn_caloires(data["take_off_cost"], data)
		data["is_flying"] = true
		data["change_state"].emit("Flying")
	character_body.set_collision_mask_value(1, false)
	character_body.set_collision_mask_value(2, true)
	super.success()

func start():
	character_body = data["character_body"]
	flight_agent = data["flight_agent"]
