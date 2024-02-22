class_name MinHeap

const MAX_DEPTH = 3
const LEFT_CHILD = 1
const RIGHT_CHILD = 2

var heap: Array[HeapItem]

class HeapItem:
	var sort_value: Variant
	var value: Variant

	func _init(_sort_value: Variant, _value: Variant) -> void:
		self.sort_value = _sort_value
		self.value = _value

func _init() -> void:
	heap = []

func _get_childs_parent_index(index: int) -> int:
	return floori((index-1.0)/2)

func _get_left_child_index(index: int) -> int:
	return (2 * index)+LEFT_CHILD

func _get_right_child_index(index: int) -> int:
	return (2 * index)+RIGHT_CHILD

func _heapify_up(_index: int) -> void:
	var index = _index
	var new_item: HeapItem = heap[index]
	var parent_index: int = _get_childs_parent_index(index)
	var parent: HeapItem = heap[parent_index]
	while index > 0 and parent.sort_value > new_item.sort_value:
		_swap(index, parent_index)
		parent_index = _get_childs_parent_index(index)
		index = parent_index

func _heapify_down(_index: int) -> void:
	var smallest_index: int = _index
	var left_index: int = _get_left_child_index(_index)
	var right_index: int = _get_right_child_index(_index)
	if left_index < len(heap) and heap[left_index].sort_value < heap[smallest_index].sort_value:
		smallest_index = left_index
	if right_index < len(heap) and heap[right_index].sort_value < heap[smallest_index].sort_value:
		smallest_index = right_index
	if smallest_index != _index:
		_swap(_index, smallest_index)
		_heapify_down(smallest_index)


func _swap(index_a: int, index_b: int) -> void:
	var temp = heap[index_a]
	heap[index_a] = heap[index_b]
	heap[index_b] = temp

func push(item: HeapItem) -> void:
	heap.push_back(item)
	_heapify_up(len(heap)-1)

func pop_front() -> HeapItem:
	if len(heap) == 0 :
		return null
	_swap(0, len(heap) - 1)
	var min_item = heap.pop_back()
	_heapify_down(0)
	return min_item

func get_root() -> HeapItem:
	if len(heap) == 0 :
		return null
	return heap[0]


