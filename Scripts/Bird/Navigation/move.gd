extends Task

class_name Move

var bird: Bird

func _init(parent_bird: Bird, node_name:String="Move") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	bird.next_path_position = bird.nav_agent.get_next_path_position()
	bird.direction = bird.to_local(bird.next_path_position).normalized()
	bird.animatated_spite.flip_h = bird.direction.x < 0
	bird.velocity = bird.direction * bird.SPEED_INSANE * get_physics_process_delta_time()
	var bird_at_target = bird.at_target()
	# If the bird has been told to stop the this should not be running
	if not bird_at_target and bird.nav_agent.is_target_reachable() and not bird.stop_now:
		bird.move_and_slide()
		super.running()	
	elif bird.stop_now:
		super.success()
	elif bird_at_target:
		bird.target_reached = true
		super.success()
	elif not bird.nav_agent.is_target_reachable():
		super.fail()
	
func start()->void:
	super.start()
