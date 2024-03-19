extends Steering

class_name Avoidance

var feeler_distance: float
var distance = 20

func calculate()->Vector2:
	var local_force = Vector2.ZERO
	var state_space = bird.get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(bird.global_position, bird.global_position + (bird.velocity.normalized() * feeler_distance), bird.collision_mask)
	var result = state_space.intersect_ray(query)
	if DebugGizmos.enabled:
		bird.debug_feeler.draw([bird.global_position, bird.global_position + (bird.velocity.normalized() * feeler_distance)])
	if not result.is_empty(): 
		var to_bird = bird.global_position - result.position
		var force_magnatiude = (feeler_distance - to_bird.length()) * (distance)
		#Invert the wander direction to force the bird to turn around and not be fighting with wander forcing the bird in the other direction
		bird.target = -bird.target
		# This is normal
		local_force = result.normal * force_magnatiude
	return local_force
