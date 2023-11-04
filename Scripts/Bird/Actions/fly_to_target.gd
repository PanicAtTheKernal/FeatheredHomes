extends Task

class_name FlyToTarget

@export_range(0.1, 3.0)
var speed_multiplier: float = 1.3

var flight_agent: NavigationAgent2D
var character_body: CharacterBody2D

func run():
	var direction = character_body.to_local(flight_agent.get_next_path_position()).normalized()
	character_body.velocity = direction * (BirdHelperFunctions.SPEED*speed_multiplier) * self.data["delta"]
	
	if flight_agent.is_target_reached() == false and flight_agent.is_target_reachable():
		character_body.move_and_slide()
		super.running()
	elif flight_agent.is_target_reached() and BirdHelperFunctions.character_at_target(character_body.global_position, data["target"]):
		data["is_flying"] = false
		data["target_reached"] = true
		super.success()
	elif not flight_agent.is_target_reachable():
		super.fail()

	
func start():
	flight_agent = self.data["flight_agent"]
	character_body = self.data["character_body"]
	super.start()
