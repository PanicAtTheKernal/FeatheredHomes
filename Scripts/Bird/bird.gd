extends CharacterBody2D

class_name Bird

enum States {
	GROUND,
	AIR,
	MIGRATING
}

enum BirdCalls {
	STOP,
	LOVE,
	NEST_BUILT,
	LEAVE
}

const SPEED = 60
const SPEED_INSANE = 40**2
const ARRIVAL_THRESHOLD = 5.0
const CALORIES_BURNED = 10
const TEEN_THRESHOLD = 4
const YOUNG_ADULT_THRESHOLD = 8
const ADULT_THRESHOLD = 20

# Bird Nodes
@export
var nav_agent: NavigationAgent2D
@export
var animatated_spite: BirdAnimation
@export
var love_particles: GPUParticles2D
@export
var sound_player: AudioStreamPlayer2D
@export
var behavioural_tree: BirdBehaviouralTree
@export
var tile_map: TileMapManager
# Bird Information
@export
var info: BirdInfo
@export
var species: BirdSpecies
# External Resources
@export
var world_resources: WorldResources
@export
var nest_manager: NestManager
@export
var bird_manager: BirdManager

var id: int
var stop_now: bool
var current_age: int
var target: Vector2
var direction: Vector2
var next_path_position: Vector2
var current_stamina: float
var distance_to_target: float
var target_reached: bool = false
var is_distance_calculated: bool = false
var state: States = States.AIR
var current_tile: String
var current_partition: Vector2i
# var middle_of_love: bool
var mate: bool
var mass: float
# Only birds that have the find neartest partner action will have this set 
var partner: int
var nest: WorldResource
var logger_key = {
	"type": Logger.LogType.NAVIGATION,
	"obj": "Bird <ID:"+str(id)+">"
}
signal change_state(new_state: String, should_flip_h: bool)
signal listener(call: String, messager_id: int, data: Variant)

func _ready():
	_increament_age()
	stop_now = false
	mate = true
	partner = -1
	behavioural_tree.bird_id = id
	mass = info.species.size * 0.1
	animatated_spite.sprite_frames = species.animations
	listener.connect(_on_call)
	current_stamina = species.stamina
	current_partition = tile_map.get_partition_index(tile_map.world_to_map_space(global_position))
	bird_manager.add_bird_resource(current_partition,Vector2i(0,0), self)
	 #Start the navaiagation timer at differnet times for each bird
	
func _physics_process(_delta: float) -> void:
	# Physics process starts before ready is called
	#await get_tree().create_timer(0.5, true, true).timeout
	var new_partition = tile_map.get_partition_index(tile_map.world_to_map_space(global_position))
	if current_partition != new_partition and tile_map.partition_keys.has(new_partition):
		Logger.print_debug("Entered new partition: " + str(new_partition), logger_key)
		bird_manager.add_bird_resource(new_partition, current_partition, self)
		current_partition = new_partition


func update_target(new_target: Vector2)->void:
	target = new_target
	if nav_agent.target_position == target:
		return
	nav_agent.target_position = target
	nav_agent.get_next_path_position()
	await get_tree().create_timer(0.1).timeout
	#await nav_agent.path_changed
	is_distance_calculated = false 

## Function to make sure the bird is at the target
func at_target()->bool:
	# Round the number to the nearest whole number because float precision was causing accuracy issues 
	var character_pos_rounded = round(global_position)
	var target_rounded = round(target)
	var test = (character_pos_rounded - target_rounded).length()
	if test < ARRIVAL_THRESHOLD:
		return true
	else:
		return false

func burn_caloires():
	var movement_cost = species.ground_cost if state == States.GROUND else species.flight_cost
	var amount = CALORIES_BURNED * species.size + movement_cost
	current_stamina = clamp(current_stamina - amount, 0, species.max_stamina)
	info.species.stamina = current_stamina
	# Death State
	if current_stamina == 0:
		_die()
	
func add_caloires(amount:float):
	current_stamina = clamp(current_stamina + amount, 0, species.max_stamina)
	info.species.stamina = current_stamina	
	
func find_shortest_path_min_heap(map_cords: Vector2, partition_index: Vector2i, group: String)->MinHeap.HeapItem:
	var resources = world_resources.get_resource_partition_group(partition_index, group)
	var distances: MinHeap = MinHeap.new()
	for loc in resources:
		# Only add resources that are full
		var resource = resources[loc]
		if resource.current_state == "Empty":
			continue
		var distance = map_cords.distance_to(loc)
		distances.push(MinHeap.HeapItem.new(distance, loc))
	return distances.get_root()

func check_closest_adjacent_cells(map_cords: Vector2, group: String)->MinHeap.HeapItem:
	var neighbour_heap = MinHeap.new()
	var row = current_partition.x
	var col = current_partition.y
	# This is faster
	var neighbours = [
		Vector2i(row + 1, col),
		Vector2i(row + 1, col+1),
		Vector2i(row + 1, col-1),
		Vector2i(row - 1, col),
		Vector2i(row - 1, col+1),
		Vector2i(row - 1, col-1),
		Vector2i(row, col + 1),
		Vector2i(row, col - 1)
	]
	for neighbour in neighbours:
		if not tile_map.check_if_within_partition_bounds(neighbour):
			continue
		if world_resources.get_resource_partition_group(neighbour, species.diet).is_empty(): 
			continue
		var bird_map_cords: Vector2 = tile_map.world_to_map_space(global_position)	
		var distance = bird_map_cords.distance_to(tile_map.get_partition_midpoint(neighbour))
		neighbour_heap.push(MinHeap.HeapItem.new(distance, neighbour))
	while not neighbour_heap.is_empty():
		var closest_neighbour = neighbour_heap.pop_front()
		var shortest_distance = find_shortest_path_min_heap(map_cords, closest_neighbour.value, group) 
		if shortest_distance != null:
			return shortest_distance
	return null

func find_nearest_bird(condition: Callable, partition: Vector2i)->MinHeap.HeapItem:
	var bird_map_cords: Vector2 = tile_map.world_to_map_space(global_position)	
	var birds = bird_manager.partitions[partition]
	var distances: MinHeap = MinHeap.new()
	for nearby_bird in birds:
		# Calls the lambda function expecting it to return a bool
		if condition.call(nearby_bird):
			continue
		var nearby_bird_map_cords: Vector2 = tile_map.world_to_map_space(nearby_bird.global_position)
		var distance = bird_map_cords.distance_to(nearby_bird_map_cords)
		distances.push(MinHeap.HeapItem.new(distance, nearby_bird))
	return distances.get_root()

# TODO Find a way to reduce this
func check_closest_adjacent_cells_bird(condition: Callable)->MinHeap.HeapItem:
	var neighbour_heap = MinHeap.new()
	var row = current_partition.x
	var col = current_partition.y
	# This is faster
	var neighbours = [
		Vector2i(row + 1, col),
		Vector2i(row + 1, col+1),
		Vector2i(row + 1, col-1),
		Vector2i(row - 1, col),
		Vector2i(row - 1, col+1),
		Vector2i(row - 1, col-1),
		Vector2i(row, col + 1),
		Vector2i(row, col - 1)
	]
	for neighbour in neighbours:
		if not tile_map.check_if_within_partition_bounds(neighbour):
			continue
		if bird_manager.partitions[current_partition].is_empty(): 
			continue
		var bird_map_cords: Vector2 = tile_map.world_to_map_space(global_position)	
		var distance = bird_map_cords.distance_to(tile_map.get_partition_midpoint(neighbour))
		neighbour_heap.push(MinHeap.HeapItem.new(distance, neighbour))
	while not neighbour_heap.is_empty():
		var closest_neighbour = neighbour_heap.pop_front()
		var shortest_distance = find_nearest_bird(condition, closest_neighbour.value) 
		if shortest_distance != null:
			return shortest_distance
	return null

func _die() -> void:
	info.status = "Dead"
	animatated_spite.play_dead()
	hide()
	BirdResourceManager.remove_bird(info)
	queue_free()

func _on_button_pressed():
	get_tree().call_group("BirdStat", "show")	
	get_tree().call_group("BirdStat", "load_new_bird", info)


func _on_calorie_timer_timeout() -> void:
	burn_caloires()

func _increament_age()->void:
	current_age += 1
	if current_age < TEEN_THRESHOLD:
		info.age_status = "Teen"
	elif current_age < YOUNG_ADULT_THRESHOLD:
		info.age_status = "Young adult"
	elif current_age < ADULT_THRESHOLD:
		info.age_status = "Adult"
	else:
		info.age_status = "Elder"
	if mate == false:
		mate = true
		

func _on_age_timer_timeout() -> void:
	_increament_age()
	if current_age >= species.max_age:
		_die()

func _on_call(call_message: BirdCalls, messager_id: int, data: Variant) -> void:
	match call_message:
		BirdCalls.STOP:
			Logger.print_debug("Stopping bird", logger_key)
			animatated_spite.flip_h = global_position.direction_to(data).x < 0
			stop_now = true
		BirdCalls.LOVE:
			love_particles.emitting = true
			nest = data
			partner = messager_id
			stop_now = false
			#animatated_spite.play("defualt")
		BirdCalls.NEST_BUILT:
			nest = null
		BirdCalls.LEAVE:
			nest = null
			partner = -1
			mate = false

func _on_timer_timeout() -> void:
	sound_player.play()
