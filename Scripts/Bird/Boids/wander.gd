extends Task

class_name Wander

var bird: Bird
var noise: FastNoiseLite

var frequency = 0.3
var radius = 3
var theta = 0
# Wander angle
var amplitude = 80
var distance = 10
var target: Vector2
var world_target: Vector2
var w_angle: float = 20
var force: Vector2

func _init(parent_bird: Bird, node_name:String="Wander") -> void:
	super(node_name)
	bird = parent_bird
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.set_noise_type(FastNoiseLite.TYPE_PERLIN)
	noise.set_frequency(0.01)
	noise.set_fractal_lacunarity(2)
	noise.set_fractal_gain(0.5)

func run()->void:
	force = Vector2.ZERO
	force += _wander()
	force -= _avoidance()
	var acceleration = force/ bird.mass
	bird.velocity = bird.velocity + acceleration * get_physics_process_delta_time()
	bird.move_and_slide()
	super.success()	
	#var bird_at_target = bird.at_target()
	#if not bird_at_target and bird.nav_agent.is_target_reachable():
		#bird.move_and_slide()
		#super.running()	
	#elif bird_at_target:
		#bird.target_reached = true
		#super.success()
	#elif not bird.nav_agent.is_target_reachable():
		#super.fail()
	
func start()->void:
	super.start()

func _seek(target: Vector2)->Vector2:
	var to_target = (target - bird.global_position).normalized()
	var desired = to_target * bird.SPEED
	return desired - bird.velocity
	
func _wander()->Vector2:
	var noise_value = noise.get_noise_1d(theta)
	var angle = deg_to_rad(noise_value * amplitude)
	#var angle = deg_to_rad(randi_range(-w_angle, w_angle))
	# There is only 1 rotation in a 2D space
	var rotation = bird.global_rotation

	#var displacment: Vector2 = w_angle * Vector2(randf(), randf()) * get_physics_process_delta_time()
	#target += displacment
	#target = target.limit_length(radius)
	#
	#target.x = sin(angle)
	#target.y = cos(angle)
	#
	#target.rotated(angle)
	#
	#target *= radius
	
	#target = Vector2(radius*angle, radius*angle)
	
	var local_target = target * distance
	world_target = (bird.global_position + Vector2(10,10)).rotated(angle)
	theta += frequency * get_physics_process_delta_time() * PI * 2.0
	return _seek(world_target)
	
func _avoidance()->Vector2:
	var local_force = Vector2.ZERO
	var state_space = bird.get_world_2d().direct_space_state
	# 100 = ray len
	var query = state_space.intersect_ray(PhysicsRayQueryParameters2D.create(bird.global_position, bird.global_position + bird.velocity.normalized() * 100, bird.collision_mask))
	if not query.is_empty(): 
		local_force += -query["normal"] * 1000
		#force -= bird.velocity * 50
	return local_force
