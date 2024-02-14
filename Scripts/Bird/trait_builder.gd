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
	# FindRandomSpot
	exploration_sequence.add_child(FindRandomSpot.new(bird,id+": FindRandomSpot"))
	# Navigation
	exploration_sequence.add_child(_build_navigation())
	# ReachedTarget
	exploration_sequence.add_child(ReachedTarget.new(bird,id+": ReachedTarget"))
	root_selector.add_child(exploration_sequence)

func _build_navigation()->Sequence:
	var navigation_sequence = Sequence.new(id+": NavigationSequence")
	navigation_sequence.add_child(Leaf.new(id+": Temp"))
	return navigation_sequence
