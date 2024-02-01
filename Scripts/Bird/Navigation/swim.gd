extends Task

class_name Swim

@export
var navigation_data: NavigationData
var nav_agent: NavigationAgent2D
var character_body: CharacterBody2D

var change_state

func run():
	var direction = character_body.to_local(nav_agent.get_next_path_position()).normalized()
	var should_flip_h = direction.x < 0
	change_state.emit("Water", should_flip_h)
	super.success()
	
func start():
	character_body = navigation_data.character_body
	nav_agent = navigation_data.nav_agent
	change_state = data["change_state"]
	super.start()
