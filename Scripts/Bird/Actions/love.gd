extends Task

class_name Love

var bird: Bird
var sequence_complete: bool
var started_animation: bool

func _init(parent_bird: Bird, node_name:String="Dance") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if bird.animatated_spite.finished != "dancing" and bird.animatated_spite.animation != "Dance":
		#bird.animatated_spite.play_dance_animation()
		bird.behavioural_tree.wait_for_function(bird.animatated_spite.play_dance_animation)
		bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished) 
	else:
		bird.love_particles.emitting = true
		var nest = bird.nest_manager.request_nest(bird.species.nest_type)
		var nearby_bird = bird.bird_manager.get_bird(bird.partner)
		if nearby_bird == null:
			Logger.print_fail("Fail: The bird lost the potential partner", logger_key)
			super.fail()
		nearby_bird.listener.emit(bird.BirdCalls.LOVE, bird.id, nest)
		if bird.species.coparent:
			bird.nest = nest
		bird.mate = false
		Logger.print_success("Success: The bird found love", logger_key)
		super.success()
		# started_animation = true
		# super.running()
		return
	# super.fail()
		
func start()->void:
	super.start()

