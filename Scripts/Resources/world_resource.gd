extends Resource

class_name WorldResource

var layer: int
var template: WorldResourceTemplate
var position: Vector2i
var current_state: String
var tile_map_ref: TileMap
var value: float
var amount: float

func _init(_template: WorldResourceTemplate, _position: Vector2i, inital_state: String, _tile_map_ref: TileMap, _layer: int, _value: float, _amount: float):
	self.template = _template
	self.position = _position
	self.current_state = inital_state
	self.tile_map_ref = _tile_map_ref
	self.layer = _layer
	self.value = _value
	self.amount = _amount

func update_state(new_state:String)->bool:
	# Don't update state if the state is the same
	if new_state == current_state:
		return false
	var food_state = template.get_state(new_state)
	if food_state == null:
		return false
	current_state = new_state
	return true
