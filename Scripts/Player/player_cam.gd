extends Camera2D

const MIN_ZOOM: float = 6.0
const MAX_ZOOM: float = 9.0
const TILE_SIZE: int = WorldResources.TILE_SIZE
const MAX_ZOOM_VEC: Vector2 = Vector2(MAX_ZOOM, MAX_ZOOM)
const MIN_ZOOM_VEC: Vector2 = Vector2(MIN_ZOOM, MIN_ZOOM)

@export
var zoom_increment: float = 1.0
@onready
var tile_map: TileMap = %TileMap
@onready
var world_resources: WorldResources = %WorldResources

var dragging: bool = false
var isActive: bool = true
var update_states = {
	"Empty": "Full",
	"Full": "Empty"
}
var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "PlayerCamera"
}

func _ready()->void:
	# Create the camera limits
	var map_size = tile_map.get_used_rect()
	var start = Vector2(map_size.position * TILE_SIZE)
	var end = Vector2((map_size.size + map_size.position) * TILE_SIZE)
	limit_top = start.y
	limit_left = start.x
	limit_bottom = end.y
	# Just to make the right limit is within the visible bounds of the map
	limit_right = end.x - TILE_SIZE
	
func _input(event)->void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not dragging and event.pressed:
				dragging = true
			elif dragging and not event.pressed:
				dragging = false
	
	# Move the camera
	if event is InputEventMouseMotion and dragging and isActive:
		position -= event.relative / zoom
		
	if event is InputEventMagnifyGesture:
		Logger.print_debug(event, logger_key)	
		zoom = clamp(zoom * event.factor, MIN_ZOOM_VEC, MAX_ZOOM_VEC)


	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			var mouse_position = get_global_mouse_position()
			var mouse_position_to_tile_position = tile_map.local_to_map(mouse_position)
			var resource = world_resources.get_resource(mouse_position_to_tile_position)
			world_resources.set_resource_state_from_loc(mouse_position_to_tile_position, update_states[resource.current_state])


func zoom_in()->void:
	if zoom < MAX_ZOOM_VEC:
		zoom += Vector2(zoom_increment, zoom_increment) 

func zoom_out()->void:
	if zoom > MIN_ZOOM_VEC:
		zoom -= Vector2(zoom_increment, zoom_increment) 

# This is when the dialog box show up the player camera stops
func display(message: String, heading: String = "Notice:")->void:
	Logger.print_debug("Player camera movement is disabled", logger_key)
	isActive = false

func turn_off_movement()->void:
	isActive = false

func turn_on_movement()->void:
	Logger.print_debug("Player camera movement is enabled", logger_key)	
	isActive = true
