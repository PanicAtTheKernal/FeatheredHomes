extends Task

class_name Love

var bird: Bird
var sequence_complete: bool
var started_animation: bool

func _init(parent_bird: Bird, node_name:String="Dance") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.animation != "Dance" and not started_animation:
		await bird.animatated_spite.play_dance_animation()
		started_animation = true
		super.running()
		return
	elif bird.animatated_spite.animation != "Dance" and started_animation:
		bird.love_particles.emitting = true
		bird.nest = bird.nest_manager.request_nest(bird.species.nest_type)
		bird.bird_manager.get_bird(bird.partner).listener.emit(bird.BirdCalls.LOVE, bird.id, bird.nest)
		#if bird.species.coparent:
			#bird.update_target(bird.tile_map.map_to_world_space(bird.nest.position))
		# bird.middle_of_love = false
		super.success()
	# super.fail()
		
func start()->void:
	super.start()

