extends Task

class_name CheckIfFlyingIsEfficient

## Not needed anymore
## @deprecated
##

var character_body: CharacterBody2D
var flight_agent: NavigationAgent2D

func run()->void:
	var flight_cost:float = data["total_flight_energy_cost"]
	var ground_cost:float = data["total_ground_energy_cost"]
	var path: PackedVector2Array = flight_agent.get_current_navigation_result().path
	
	if flight_cost == null:
		printerr("calculate distances node is missing")
	
	if not flight_agent.is_target_reachable() or flight_agent.get_current_navigation_result().path == PackedVector2Array([]):
		super.fail()
		return
	
	if flight_cost > ground_cost:
		super.fail()
		return
	
	data["preferred_agent"] = "flight"
	if data["is_flying"] == false:
		BirdHelperFunctions.burn_caloires(data["take_off_cost"], data)
		data["is_flying"] = true
	character_body.set_collision_mask_value(1, false)
	character_body.set_collision_mask_value(2, true)
	super.success()

func start()->void:
	character_body = data["character_body"]
	flight_agent = data["flight_agent"]
