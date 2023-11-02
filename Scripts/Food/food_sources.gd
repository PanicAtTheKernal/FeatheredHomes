class_name FoodSource

var layer: int
var food_resource: FoodResouce
var position: Vector2i
var current_state: String
var tile_map_ref: TileMap
var value: float
var amount: float

func _init(_food_resource: FoodResouce, _position: Vector2i, inital_state: String, _tile_map_ref: TileMap, _layer: int, _value: float, _amount: float):
	self.food_resource = _food_resource
	self.position = _position
	self.current_state = inital_state
	self.tile_map_ref = _tile_map_ref
	self.layer = _layer
	self.value = _value
	self.amount = _amount

func update_state(new_state:String):
	# Don't update state if the state is the same
	if new_state == current_state:
		return
	var food_state = food_resource.find_state(new_state)
	if food_state == null:
		return
	current_state = new_state
	tile_map_ref.set_cell(self.layer, self.position, food_state.source_id, food_state.altas_cords, food_state.alternative_tile)
