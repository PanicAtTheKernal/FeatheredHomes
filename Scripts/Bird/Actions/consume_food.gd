extends Task

class_name Consume

var bird: Bird
var target_resource: String

func _init(parent_bird: Bird, resource_name: String, node_name:String="Consume") -> void:
	super(node_name)
	bird = parent_bird
	target_resource = resource_name

func run()->void:
	if not bird.at_target():
		super.fail()
		return
	var target_map_cords: Vector2i = bird.tile_map.world_to_map_space(bird.target)
	# Make sure that there is still food at the target location
	var resource = bird.world_resources.get_resource(target_resource, target_map_cords)
	if resource != null and resource.current_state == "Full":
		var value = resource.value
		await bird.animatated_spite.play_eating_animation()
		await bird.animatated_spite.animation_group_finished
		# Wait until the eating animation is completed before moving on
		if bird.animatated_spite.finished != "eating":
			super.fail()
			return
		# Sticks have zero caloires ;)
		bird.add_caloires(resource.value)
		bird.world_resources.set_resource_state(resource, "Empty")
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
