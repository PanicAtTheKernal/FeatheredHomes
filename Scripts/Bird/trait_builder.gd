extends Node

class_name TraitBuilder

var bird: Bird
var id: String
var root: BirdBehaviouralTree
var root_selector: Selector
var world_resources: WorldResources
var animated_sprite: AnimatedSprite2D
var at_target_lambda: Callable
var is_nest_available: Callable
var is_bird_ready_to_mate: Callable

var logger_key = {
	"type": Logger.LogType.BUILDER,
	"obj": "TraitBuilder"
}

func _init(new_bird: Bird) -> void:
	self.bird = new_bird
	root = new_bird.behavioural_tree
	world_resources = new_bird.world_resources
	animated_sprite = new_bird.animatated_spite
	at_target_lambda = func(): return bird.at_target()
	is_nest_available = func(): return bird.nest_manager.has_available_nest(bird.species.nest_type)
	is_bird_ready_to_mate = func(): return bird.mate
	id = str(new_bird.id)


func build_root()->void:
	root_selector = Selector.new(id+": RootSelector")
	root.add_child(root_selector)

func build_exploration()->void:
	var exploration_sequence = Sequence.new(id+": ExplorationSequence")
	# Conditions
	var exploration_condition_selector = Selector.new(id+": ExplorationConditionSelector")
	var is_energetic = Inverter.new(id+": IsEnergetic")
	is_energetic.add_child(LessThan.new(bird, "current_stamina", (bird.species.max_stamina * bird.species.threshold),id+": CheckStamina"))
	var is_barren = Inverter.new(id+": IsBarren")
	is_barren.add_child(FindNearestResource.new(bird, bird.species.diet, id+": FindNearestFood"))
	exploration_condition_selector.add_child(is_energetic)
	exploration_condition_selector.add_child(is_barren)
	# exploration_condition_selector.add_child(Equal.new(bird, "stop_now", false, id+": NotStopped"))
	exploration_sequence.add_child(exploration_condition_selector)
	# Navigation
	exploration_sequence.add_child(_build_wander())
	root_selector.add_child(exploration_sequence)

func build_foraging()->void:
	var foraging_sequence = Sequence.new(id+": ForagingSequence")
	# var is_middle_of_love = Inverter.new(id+": IsNotMiddleOfLove")
	# is_middle_of_love.add_child(Equal.new(bird, "middle_of_love", true, id+": IsMiddleOfLove"))
	# foraging_sequence.add_child(is_middle_of_love)
	# foraging_sequence.add_child(Equal.new(bird, "stop_now", false, id+": NotStopped"))
	foraging_sequence.add_child(LessThan.new(bird, "current_stamina", (bird.species.max_stamina * bird.species.threshold),id+": CheckStamina"))
	foraging_sequence.add_child(FindNearestResource.new(bird, bird.species.diet, id+": FindNearestFood"))
	foraging_sequence.add_child(_build_navigation())
	foraging_sequence.add_child(ConsumeFood.new(bird, id+": ConsumeFood"))
	root_selector.add_child(foraging_sequence)


func build_partner()->void:
	var partner_sequence = Sequence.new(id+": PartnerSequence")
	# CheckIfOldEnough
	partner_sequence.add_child(GreaterThan.new(bird, "current_age", bird.TEEN_THRESHOLD, id+": CheckIfOldEnough"))
	partner_sequence.add_child(Equal.new(bird, "nest", null, id+": NoNest"))
	#partner_sequence.add_child(Equal.new(bird, "partner", null, id+": HaveNest"))	
	if bird.info.gender == "male":
		# Male mating conditions
		partner_sequence.add_child(Equal.new(bird, is_bird_ready_to_mate, true, id+": ReadyToMate"))
		partner_sequence.add_child(Equal.new(bird, "partner", -1, id+": HasNoMate"))
		partner_sequence.add_child(Equal.new(bird, is_nest_available, true, id+": NestAvailable"))
		partner_sequence.add_child(FindNearestBird.new(bird, id+": FindNearestBird"))
		partner_sequence.add_child(_build_navigation())
		partner_sequence.add_child(Love.new(bird, id+": Love"))
		# partner_sequence.add_child(_build_navigation())		
		# CheckIfTargetReached
	elif bird.info.gender == "female":
		var condition= func(): return bird.stop_now
		partner_sequence.add_child(Stop.new(bird,condition, id+": Stop"))
		partner_sequence.add_child(Land.new(bird,id+": Land"))	
		# partner_sequence.add_child(not_stopped_by_inverter)
		# partner_sequence.add_child(_build_navigation())		
	root_selector.add_child(partner_sequence)

func build_parenting()->void:
	var parenting_sequence = Sequence.new(id+": ParentingSequence")
	var has_nest = Inverter.new(id+": HasNest")
	has_nest.add_child(Equal.new(bird, "nest", null, id+": NoNest"))
	parenting_sequence.add_child(has_nest)
	if bird.species.coparent:
		pass
	root_selector.add_child(parenting_sequence)

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
	navigation_sequence.add_child(_build_check_if_reached_target())
	# Stop
	navigation_sequence.add_child(Stop.new(bird,at_target_lambda, id+": Stop"))
	navigation_sequence.add_child(Land.new(bird,id+": Land"))
	return navigation_sequence

func _build_wander()->Sequence:
	var wander_sequence = Sequence.new(id+": WanderSequence")
	wander_sequence.add_child(Fly.new(bird, id+": Fly"))
	wander_sequence.add_child(Wander.new(bird, id+": Wander"))
	return wander_sequence

func _build_ground_sequence()->Sequence:
	var ground_sequence = Sequence.new(id+": GroundSequence")
	var distance_lamdba = func(): return bird.global_position.distance_to(bird.target)
	ground_sequence.add_child(LessThan.new(bird,distance_lamdba,bird.species.ground_max_distance, id+": CheckIfMovingOnGround"))
	ground_sequence.add_child(CheckGroundType.new(bird, id+": CheckGroundType"))
	ground_sequence.add_child(_build_walking_sequence())
	if bird.species.can_swim:
		ground_sequence.add_child(_build_swimming_sequence())		
	return ground_sequence

func _build_walking_sequence()->Sequence:
	var walking_sequence = Sequence.new(id+": WalkingSequence")
	walking_sequence.add_child(_build_check_if_walking())
	walking_sequence.add_child(Walk.new(bird, id+": Walk"))
	return walking_sequence

func _build_swimming_sequence()->Sequence:
	var swimming_sequence = Sequence.new(id+": SwimmingSequence")
	swimming_sequence.add_child(_build_check_if_swimming())
	swimming_sequence.add_child(Swim.new(bird, id+": Swim"))
	return swimming_sequence

func _build_flying_sequence()->Sequence:
	var flying_sequence = Sequence.new(id+": FlyingSequence")
	var not_at_targert_inverter = Inverter.new(id+": IsNotAtTargert")
	not_at_targert_inverter.add_child(Equal.new(bird, "target_reached", true, id+": AtTarget"))
	#flying_sequence.add_child(TakeOff.new(bird, id+": TakeOff"))	
	flying_sequence.add_child(Fly.new(bird, id+": Fly"))
	return flying_sequence

func _build_check_if_reached_target()->Task:
	return Equal.new(bird, at_target_lambda, true, id+": CheckIfReachedTarget")

func _build_check_if_swimming()->Sequence:
	var check_if_swimming_sequence = Sequence.new(id+": CheckIfSwimmingSequence")
	check_if_swimming_sequence.add_child(Equal.new(bird, "current_tile", "Water", id+": CheckOnWaterTile"))
	var not_at_targert_inverter = Inverter.new(id+": IsNotAtTargert")
	not_at_targert_inverter.add_child(Equal.new(bird, "target_reached", true, id+": AtTarget"))
	check_if_swimming_sequence.add_child(not_at_targert_inverter)
	return check_if_swimming_sequence

func _build_check_if_walking()->Sequence:
	var check_if_walking_sequence = Sequence.new(id+": CheckIfSwimmingSequence")
	check_if_walking_sequence.add_child(Equal.new(bird, "current_tile", "Ground", id+": CheckOnGroundTile"))
	var not_at_targert_inverter = Inverter.new(id+": IsNotAtTargert")
	not_at_targert_inverter.add_child(Equal.new(bird, "target_reached", true, id+": AtTarget"))
	check_if_walking_sequence.add_child(not_at_targert_inverter)
	return check_if_walking_sequence
