extends Task

class_name Arrive

var bird: Bird
var slowing: float
var force: Vector2
#Debug
var debug_feeler: DebugGizmos.DebugLine
var debug_displacement: DebugGizmos.DebugLine
var debug_velocity: DebugGizmos.DebugLine


func _init(parent_bird: Bird, node_name:String="Arrive") -> void:
	super(node_name)
	bird = parent_bird
	slowing = 22.0

func run():
	force = Vector2.ZERO
	force += _arrive(bird.target)
	print(bird.global_position.distance_to(bird.target))
	# if DebugGizmos.enabled:
	# 	debug_velocity.draw([bird.global_position, (bird.global_position+force)])
	var acceleration = force/ bird.mass
	bird.velocity = bird.velocity + acceleration * get_physics_process_delta_time()
	if bird.velocity.length() > 0:
		bird.animatated_spite.flip_h = bird.velocity.normalized().x < 0
	bird.move_and_slide()
	super.success()

func start():
	super.start()

func _arrive(target_pos: Vector2)-> Vector2:
	var to_target = target_pos - bird.global_position
	# If the distance is zero, bad things happen
	var lend = to_target.length()
	if to_target.length() <= 0:
		return Vector2.ZERO
	var distance = to_target.length()
	var ramped = (distance / slowing) * (bird.SPEED)
	var clamped = min(ramped, (bird.SPEED))
	var desired: Vector2 = (to_target*clamped)/distance
	return desired - bird.velocity        
