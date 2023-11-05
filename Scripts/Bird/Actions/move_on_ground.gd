extends Task

class_name MoveOnGround

@export_range(0.1, 3.0)
var speed_multiplier: float = 1.0

var ground_agent: NavigationAgent2D
var character_body: CharacterBody2D

func run():
	var direction = character_body.to_local(ground_agent.get_next_path_position()).normalized()
	character_body.velocity = direction * BirdHelperFunctions.SPEED * self.data["delta"]
	
	var is_character_at_target = BirdHelperFunctions.character_at_target(character_body.global_position, data["target"])
	if  is_character_at_target == false and ground_agent.is_target_reachable():
		var should_flip_h = direction.x < 0
		character_body.move_and_slide()
		BirdHelperFunctions.find_tile_type(character_body.global_position, should_flip_h, data)
		super.running()	
	elif is_character_at_target:
		data["target_reached"] = true
		super.success()
	elif not ground_agent.is_target_reachable():
		super.fail()
	
func start():
	ground_agent = self.data["ground_agent"]
	character_body = self.data["character_body"]
	super.start()
