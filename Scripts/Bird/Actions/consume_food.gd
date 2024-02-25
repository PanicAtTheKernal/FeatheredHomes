extends Task

class_name ConsumeFood

var bird: Bird

func _init(parent_bird: Bird, node_name:String="ConsumeFood") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	if not bird.at_target():
		super.fail()
		return
	var target_map_cords: Vector2i = bird.tile_map.world_to_map_space(bird.target)
	# Make sure that there is still food at the target location
	var resource = bird.world_resources.get_resource("Food", target_map_cords)
	if resource != null and resource.current_state == "Full":

		# await bird.animatated_spite.update_state("Eat")
		await bird.animatated_spite.play_eating_animation()
		# Wait until the eating animation is completed before moving on
		if bird.animatated_spite.animation != "default":
			super.fail()
			return
		bird.add_caloires(resource.value)
		bird.world_resources.set_resource_state(resource, "Empty")
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
