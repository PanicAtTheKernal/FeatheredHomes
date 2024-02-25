extends Task

class_name FindNearestFood


var bird: Bird

func _init(parent_bird: Bird, node_name: String="FindNearestFood") -> void:
	super(node_name)
	bird = parent_bird

func run()->void:
	var bird_map_cords: Vector2 = bird.tile_map.world_to_map_space(bird.global_position)
	var shortest_distance = find_shortest_path_min_heap(bird_map_cords, bird.current_partition, "Food")
	# If no food is found then return fail
	if shortest_distance == null:
		shortest_distance = check_closest_adjacent_cells(bird_map_cords, "Food")
		if shortest_distance == null:
			super.fail()
			return
	# Convert the shortest distance back into world space
	shortest_distance.value = bird.tile_map.map_to_world_space(shortest_distance.value)
	Logger.print_debug("[New target] "+str(shortest_distance.value), logger_key)
	await bird.update_target(shortest_distance.value)
	super.success()

func find_shortest_path_min_heap(map_cords: Vector2, partition_index: Vector2i, group: String)->MinHeap.HeapItem:
	var resources = bird.world_resources.get_resource_partition_group(partition_index, group)
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
	var row = bird.current_partition.x
	var col = bird.current_partition.y
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
		if not bird.tile_map.check_if_within_partition_bounds(neighbour):
			continue
		if bird.world_resources.get_resource_partition_group(neighbour, "Food").is_empty():
			continue
		var bird_map_cords: Vector2 = bird.tile_map.world_to_map_space(bird.global_position)	
		var distance = bird_map_cords.distance_to(bird.tile_map.get_partition_midpoint(neighbour))
		neighbour_heap.push(MinHeap.HeapItem.new(distance, neighbour))
	while not neighbour_heap.is_empty():
		var closest_neighbour = neighbour_heap.pop_front()
		var shortest_distance = find_shortest_path_min_heap(map_cords, closest_neighbour.value, group)
		if shortest_distance != null:
			return shortest_distance
	return null
