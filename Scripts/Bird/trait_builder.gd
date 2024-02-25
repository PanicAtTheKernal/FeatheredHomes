extends Node

class_name TraitBuilder

var bird: Bird
var id: String
var root: BirdBehaviouralTree
var root_selector: Selector
var world_resources: WorldResources
var animated_sprite: AnimatedSprite2D

var logger_key = {
	"type": Logger.LogType.BUILDER,
	"obj": "TraitBuilder"
}

func _init(new_bird: Bird) -> void:
	self.bird = new_bird
	root = new_bird.behavioural_tree
	world_resources = new_bird.world_resources
	animated_sprite = new_bird.animatated_spite
	id = str(new_bird.id)


func build_root()->void:
	root_selector = Selector.new(id+": RootSelector")
	root.add_child(root_selector)

func build_exploration()->void:
	var exploration_sequence = Sequence.new(id+": ExplorationSequence")
	# Conditions
	var exploration_condition_selector = Selector.new(id+": ExplorationConditionSelector")
	var is_energetic = Inverter.new(id+": IsEnergetic")
	is_energetic.add_child(CheckStamina.new(bird, id+": CheckStamina"))
	var is_barren = Inverter.new(id+": IsBarren")
	is_barren.add_child(FindNearestFood.new(bird, id+": FindNearestFood"))
	exploration_condition_selector.add_child(is_energetic)
	exploration_condition_selector.add_child(is_barren)
	exploration_sequence.add_child(exploration_condition_selector)
	# Navigation
	exploration_sequence.add_child(_build_wander())
	root_selector.add_child(exploration_sequence)

func build_foraging()->void:
	var foraging_sequence = Sequence.new(id+": ForagingSequence")
	foraging_sequence.add_child(CheckStamina.new(bird, id+": CheckStamina"))
	foraging_sequence.add_child(FindNearestFood.new(bird, id+": FindNearestFood"))
	foraging_sequence.add_child(_build_navigation())
	foraging_sequence.add_child(ConsumeFood.new(bird, id+": ConsumeFood"))
	root_selector.add_child(foraging_sequence)

func _build_navigation()->Sequence:
	var navigation_sequence = Sequence.new(id+": NavigationSequence")
	# MovementSelector
	var movement_selector = Selector.new(id+": MovementSelector")
	movement_selector.add_child(_build_ground_sequence())
	if bird.species.can_fly:
		movement_selector.add_child(_build_flying_sequence())
	navigation_sequence.add_child(movement_selector)
	# Move
	navigation_sequence.add_child(Move.new(bird, id+": Move"))
	# CheckIfTargetReached
	navigation_sequence.add_child(CheckIfReachedTarget.new(bird, id+": CheckIfReachedTarget"))
	# Stop
	navigation_sequence.add_child(Stop.new(bird, id+": Stop"))
	return navigation_sequence

func _build_wander()->Sequence:
	var wander_sequence = Sequence.new(id+": WanderSequence")
	wander_sequence.add_child(Fly.new(bird, id+": Fly"))
	wander_sequence.add_child(Wander.new(bird, id+": Wander"))
	return wander_sequence

func _build_ground_sequence()->Sequence:
	var ground_sequence = Sequence.new(id+": GroundSequence")
	ground_sequence.add_child(CheckIfMovingOnGround.new(bird, id+": CheckIfMovingOnGround"))
	ground_sequence.add_child(CheckGroundType.new(bird, id+": CheckGroundType"))
	ground_sequence.add_child(_build_walking_sequence())
	if bird.species.can_swim:
		ground_sequence.add_child(_build_swimming_sequence())		
	return ground_sequence

func _build_walking_sequence()->Sequence:
	var walking_sequence = Sequence.new(id+": WalkingSequence")
	walking_sequence.add_child(CheckIfWalking.new(bird, id+": CheckIfWalking"))
	walking_sequence.add_child(Walk.new(bird, id+": Walk"))
	return walking_sequence

func _build_swimming_sequence()->Sequence:
	var swimming_sequence = Sequence.new(id+": SwimmingSequence")
	swimming_sequence.add_child(CheckIfSwimming.new(bird, id+": CheckIfSwimming"))
	swimming_sequence.add_child(Swim.new(bird, id+": Swim"))
	return swimming_sequence

func _build_flying_sequence()->Sequence:
	var flying_sequence = Sequence.new(id+": FlyingSequence")
	flying_sequence.add_child(Fly.new(bird, id+": Fly"))
	return flying_sequence
