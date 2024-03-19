extends Task

class_name WanderBehaviour

var bird: Bird

var target: Vector2
var current_angle: float = 0
var w_angle: float = 20
var force: Vector2

var behaviours: Dictionary
var max_force: float = 100


func _init(parent_bird: Bird, node_name:String="Wander") -> void:
	super(node_name)
	bird = parent_bird
	behaviours = {
		"wander" = {
			"behaviour": Wander.new(bird),
			"weight": 0.4
		},
		"avoidance" = {
			"behaviour": Avoidance.new(bird),
			"weight": 0.8
		},
	}


func run()->void:
	force = Vector2.ZERO
	for behaviour in behaviours.values():
		var b_force: Vector2 = behaviour.behaviour.calculate()
		if is_nan(b_force.x) or is_nan(b_force.y):
			b_force = Vector2.ZERO
		force += b_force
		var i = force.length()
		if force.length() > max_force:
			force = force.limit_length(max_force)
			break
	#force += _wander()
	#force += _avoidance()
	if DebugGizmos.enabled:
		bird.debug_velocity.draw([bird.global_position, (bird.global_position+force)])
	var acceleration = force/ bird.mass
	bird.animatated_spite.flip_h = bird.velocity.normalized().x < 0
	bird.velocity = bird.velocity + acceleration * get_physics_process_delta_time()
	bird.move_and_slide()
	super.success()
	
func start()->void:
	super.start()

	

