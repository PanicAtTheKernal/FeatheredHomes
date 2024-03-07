extends Task

class_name Move

var bird: Bird
var extra_check: Callable

func _init(parent_bird: Bird, target_available_check: Callable, node_name:String="Move") -> void:
	super(node_name)
	bird = parent_bird
	extra_check = target_available_check

func run()->void:
	bird.next_path_position = bird.nav_agent.get_next_path_position()
	bird.direction = bird.to_local(bird.next_path_position).normalized()
	bird.animatated_spite.flip_h = bird.direction.x < 0
	bird.velocity = bird.direction * bird.SPEED_INSANE * get_physics_process_delta_time()
	var bird_at_target = bird.at_target()
	var target_avaliable = extra_check.call()
	# If the bird has been told to stop the this should not be running
	if not bird_at_target and bird.nav_agent.is_target_reachable() and not bird.stop_now and target_avaliable:
		bird.move_and_slide()
		Logger.print_running(str("Running: Moving towards ", bird.target), logger_key)
		super.running()
	elif bird.stop_now:
		Logger.print_success(str("Success: Bird has been told to stop moving"), logger_key)
		super.success()
	elif bird_at_target:
		bird.target_reached = true
		Logger.print_success(str("Success: Arrived at target ", bird.target), logger_key)
		super.success()
	elif not bird.nav_agent.is_target_reachable():
		Logger.print_fail(str("Fail: Bird can't reach target ", bird.target), logger_key)
		super.fail()
	elif not target_avaliable:
		Logger.print_fail(str("Fail: Target is no longer available", bird.target), logger_key)
		super.fail()
	
func start()->void:
	super.start()
