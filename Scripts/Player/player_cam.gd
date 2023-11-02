extends Camera2D

const MIN_ZOOM: float = 5.0
const MAX_ZOOM: float = 9.0
const MAX_ZOOM_VEC: Vector2 = Vector2(MAX_ZOOM, MAX_ZOOM)
const MIN_ZOOM_VEC: Vector2 = Vector2(MIN_ZOOM, MIN_ZOOM)

@export
var zoom_increment: float = 0.2
@export
var tile_map: TileMap

var dragging: bool = false

var current_state: String
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not dragging and event.pressed:
				dragging = true
			elif dragging and not event.pressed:
				dragging = false
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom < MAX_ZOOM_VEC:
			zoom += Vector2(zoom_increment, zoom_increment) 
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom > MIN_ZOOM_VEC:
			zoom -= Vector2(zoom_increment, zoom_increment) 
		
	
	if event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom
