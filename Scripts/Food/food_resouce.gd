extends Resource
class_name FoodResouce

@export_category("FoodResource")
@export
var name:String = ""

@export_category("States")
@export
var states: Array[FoodState]

func find_state(state_name:String) -> FoodState:
	for state in states:
		if state.state_name == state_name:
			return state
	return null

func get_atlas_cords()->Array[Vector2i]:
	var result: Array[Vector2i] = []
	for state in states:
		result.append(state.altas_cords)
	return result
