extends Task

class_name WanderBehaviour

var bird: Bird
var noise: FastNoiseLite

var frequency = 0.3
var radius = 10
var theta = 0
# Wander angle
var amplitude = 160
var distance = 20
var feeler_distance: float
var target: Vector2
var world_target: Vector2
var current_angle: float = 0
var w_angle: float = 20
var force: Vector2
var jitter = 3.0
#Debug
var debug_feeler: DebugGizmos.DebugLine
var debug_displacement: DebugGizmos.DebugLine
var debug_velocity: DebugGizmos.DebugLine

var max_force = 30

func _init(parent_bird: Bird, node_name:String="Wander") -> void:
	super(node_name)
	bird = parent_bird
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	noise.set_frequency(0.01)
	noise.set_fractal_lacunarity(2)
	noise.set_fractal_gain(0.5)
	feeler_distance = distance + 10

func run()->void:
	force = Vector2.ZERO
	var forces: Array[Vector2] = []
	forces.push_back(_wander() * 0.4) 
	forces.push_back(_avoidance() * 0.8) 	
	#force += _avoidance() 
	
	for b_force: Vector2 in forces:
		if is_nan(b_force.x) or is_nan(b_force.y):
			force = Vector2.ZERO
		force += b_force
		if force.length() > max_force:
			force = force.limit_length(max_force)
			break
	
	
	if DebugGizmos.enabled:
		debug_velocity.draw([bird.global_position, (bird.global_position+force)])
	var acceleration = force/ bird.mass
	bird.animatated_spite.flip_h = bird.velocity.normalized().x < 0
	bird.velocity = bird.velocity + acceleration * get_physics_process_delta_time()
	bird.move_and_slide()
	super.success()
	
func start()->void:
	super.start()
	if DebugGizmos.enabled:
		debug_feeler = DebugGizmos.DebugLine.new(Color.ORANGE)
		debug_displacement = DebugGizmos.DebugLine.new(Color.RED)
		debug_velocity = DebugGizmos.DebugLine.new(Color.GREEN)
		add_child(debug_feeler)
		add_child(debug_displacement)	
		add_child(debug_velocity)

func _seek(seek_target: Vector2)->Vector2:
	var to_target = (seek_target - bird.global_position).normalized()
	var desired = to_target * bird.SPEED
	return desired - bird.velocity
	
func _wander()->Vector2:
	var noise_value = noise.get_noise_1d(theta)
	var angle = deg_to_rad(noise_value * amplitude)
	# Get new direction but it's not on the circle circumference
	target += Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0)).rotated(angle)
	# Need to place the target back onto the circumference, normalise it so target is less than 1
	# and then times it by the radius of the circle
	target = target.normalized() * radius
	# This where you move the target to be infront of the bird, moving it forward with the new vector
	var local_target = Vector2.ZERO	
	# There is no forward vector in a 2D space
	# The bird can go up, down, left or right, so the target becomes the direction
	local_target = target.normalized() * distance
	world_target = (bird.global_position + local_target)
	if DebugGizmos.enabled:
		debug_displacement.draw([bird.global_position, world_target])
	theta += frequency * get_physics_process_delta_time() * PI * 2.0
	return _seek(world_target)
	#return Vector2.ZERO
	
func _avoidance()->Vector2:
	var local_force = Vector2.ZERO
	var state_space = bird.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(bird.global_position, bird.global_position + (bird.velocity.normalized() * feeler_distance), bird.collision_mask)
	var result = state_space.intersect_ray(query)
	if DebugGizmos.enabled:
		debug_feeler.draw([bird.global_position, bird.global_position + (bird.velocity.normalized() * feeler_distance)])
	if not result.is_empty(): 
		var to_bird = bird.global_position - result.position
		var force_magnatiude = (feeler_distance - to_bird.length()) * (distance)
		#Invert the wander direction to force the bird to turn around and not be fighting with wander forcing the bird in the other direction
		target = -target
		local_force += result.normal * force_magnatiude
	return local_force
