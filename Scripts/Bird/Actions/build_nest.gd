extends Task

class_name BuildNest

var bird: Bird

func _init(parent_bird: Bird, node_name:String="BuildNest") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		Logger.print_fail("Fail: Bird not at nest", logger_key)
		super.fail()
		return
	var nest_map_cords: Vector2i = bird.nest.position
	if bird.nest_manager.build_nest(nest_map_cords):
		if bird.info.gender == "female" and bird.nest_manager.lay_egg(nest_map_cords):
			var partner: Bird = bird.bird_manager.get_bird(bird.partner)
			if partner != null:
				partner.listener.emit()
			bird.animatated_spite.play_nesting_animation()
			bird.behavioural_tree.wait_for_signal(bird.animatated_spite.animation_group_finished) 
			# if bird.animatated_spite.finished != "nesting":
			# 	super.fail()
			# 	return
			bird.behavioural_tree.wait_for_function(bird.nest_manager.hatch_egg.bind(nest_map_cords))
			Logger.print_success("Success: Egg hatched", logger_key)
			super.success()
			#Logger.print_fail("Fail: Female didn't hatch the egg", logger_key)
			#super.fail()
			return
		if bird.info.gender == "male":
			Logger.print_success("Success: Male helped with the nest", logger_key)
			super.success()
			return
	else:
		Logger.print_fail("Fail: Nest not built", logger_key)
		super.fail()
		return
	# Make sure that there is still food at the target location
	#if resource != null and resource.current_state == "Full":
		#var value = resource.value
		#await bird.animatated_spite.play_eating_animation()
		#await bird.animatated_spite.animation_group_finished
		## Wait until the eating animation is completed before moving on
		#if bird.animatated_spite.finished != "eating":
			#super.fail()
			#return
		## Sticks have zero caloires ;)
		#bird.add_caloires(resource.value)
		#bird.world_resources.set_resource_state(resource, "Empty")
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
