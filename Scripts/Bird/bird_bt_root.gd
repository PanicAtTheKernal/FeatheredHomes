extends Task

class_name BirdBehaviouralTree

@export_category("Nodes")
@export
var navigation_data: NavigationData

var is_ground_agent_updated: bool = false
var is_flight_agent_updated: bool = false

func _init() -> void:
	super("Root")

func _ready():
	var parent = self.get_parent()
	var species: BirdSpecies = parent.species
	#self.data = {
		#"tile_map": parent.tile_map,
		#"species": species,
		#"target": parent.target.position,
		#"target_reached": false,
		#"character_body": parent,
		#"world_resources": parent.world_resources,
		#"range": species.bird_range,
		#"take_off_cost": species.bird_take_off_cost, 
		#"flight_cost": species.bird_flight_cost,
		#"ground_cost": species.bird_ground_cost,
		#"stamina": species.bird_stamina,
		#"max_stamina": species.bird_max_stamina,
		#"is_flying": false,
		#"change_state": parent.change_state,
		#"current_ground": "",
		#"calculate_distances": true
	#}
	super.start()
	# Don't start processing the AI until the nav_agents have updated
	#set_physics_process(false)

#
# func _process(_delta):
# 	if is_ground_agent_updated:
# 		set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	run()

func _on_navigation_update_timeout():
	# If flight_agent is not set then none of the data is set
	#if self.data["flight_agent"] == null:
		#return
	#if data["ground_agent"].target_position != data["target"]:
		#self.data["flight_agent"].set_navigation_map(data["tile_map"].get_navigation_map(1))
		#self.data["flight_agent"].target_position = data["target"]
		#self.data["ground_agent"].target_position = data["target"]
		#self.data["flight_agent"].get_next_path_position()
		#self.data["ground_agent"].get_next_path_position()
		#self.data["ground_path"] = self.data["ground_agent"].get_current_navigation_result().path
	#self.data["calculate_distances"] = true
	pass

func run()->void:
	for child in get_children():
		child.run()


func _on_calorie_timer_timeout():
	# TODO add a moving check for ground
	if data["is_flying"]: 
		BirdHelperFunctions.burn_caloires(data["flight_cost"], data)
	else:
		BirdHelperFunctions.burn_caloires(data["ground_cost"], data)
	
	if data["stamina"] == 0:
		# Death State
		self.get_parent().queue_free()


func _on_ground_agent_path_changed():
	is_ground_agent_updated = true


func _on_flight_agent_path_changed():
	is_flight_agent_updated = true


func _on_ground_agent_navigation_finished():
	pass
	#data["target_reached"] = true
