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
		var nest = bird.nest_manager.request_nest(bird.species.nest_type)
		var nearby_bird = bird.bird_manager.get_bird(bird.partner)
		if nearby_bird == null:
			super.fail()
		nearby_bird.listener.emit(bird.BirdCalls.LOVE, bird.id, nest)
		if bird.species.coparent:
			bird.nest = nest
		bird.mate = false
		super.success()
	# super.fail()
		
func start()->void:
	super.start()

