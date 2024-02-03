extends Task

class_name MoveOnGround

@export_range(0.1, 3.0)
var speed_multiplier: float = 1.0

@export
var navigation_data: NavigationData
var nav_agent: NavigationAgent2D
var character_body: CharacterBody2D
@export
var calculate_distance: CalculateDistance

func run():
	var direction = character_body.to_local(nav_agent.get_next_path_position()).normalized()
	character_body.velocity = direction * BirdHelperFunctions.SPEED * self.data["delta"]
	
	var is_character_at_target = BirdHelperFunctions.character_at_target(character_body.global_position, data["target"])
	if  is_character_at_target == false and nav_agent.is_target_reachable():
		character_body.move_and_slide()
		super.running()	
	elif is_character_at_target:
		data["target_reached"] = true
		super.success()
	elif not nav_agent.is_target_reachable():
		super.fail()
	
func start():
	character_body = navigation_data.character_body
	nav_agent = navigation_data.nav_agent
	super.start()
