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
	var tile_loc: Vector2i = bird.tile_map.local_to_map(bird.target)
	# Make sure that there is still food at the target location
	if bird.world_resources.has_food(tile_loc):
		var tile = bird.world_resources.update_food_state(tile_loc, "Empty")
		bird.add_caloires(tile.value)
		bird.animatated_spite.update_state("Eat")
		bird.animatated_spite.play_eating_animation()
		# Wait until the eating animation is completed before moving on
		await bird.animatated_spite.animation_finished
	bird.target_reached = false
	super.success()
	
func start()->void:
	super.start()
