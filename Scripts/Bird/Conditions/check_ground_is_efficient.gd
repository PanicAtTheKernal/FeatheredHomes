extends Task

class_name CheckIfGroundIsEfficient

## Not needed anymore
## @deprecated
##

@export

var tile_map: TileMap
var ground_agent: NavigationAgent2D
var character_body: CharacterBody2D

func run()->void:
	var flight_cost:float = data["total_flight_energy_cost"]
	var ground_cost:float = data["total_ground_energy_cost"]
	
	if ground_cost == null:
		printerr("calculate distances node is missing")
	
	if not ground_agent.is_target_reachable() or ground_agent.get_current_navigation_result().path == PackedVector2Array([]):
		super.fail()
		return
	
	if ground_cost > flight_cost:
		super.fail()
		return
		

	self.data["preferred_agent"] = "ground"
	self.data["is_flying"] = false
	character_body.set_collision_mask_value(1, true)
	character_body.set_collision_mask_value(2, false)
	super.success()

func start()->void:
	tile_map = self.data["tile_map"]
	ground_agent = self.data["ground_agent"]
	character_body = self.data["character_body"]
