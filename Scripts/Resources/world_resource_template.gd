extends Resource

class_name WorldResourceTemplate

@export
var name:String = ""
@export_range(0.1, 1.0)
var respawn_rate: float = 0.5

@export
var states: Dictionary

func get_state(state_name:String) -> ResourceState:
	return states[state_name]

func get_atlas_cords()->Array[Vector2i]:
	var result: Array[Vector2i] = []
	for state in states.values():
		result.append(state.altas_cords)
	return result

func get_states()->Array:
	return states.keys()
