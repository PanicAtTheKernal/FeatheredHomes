extends TileMap

class_name TileMapManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_resource_sprite(resource: WorldResource, new_state: String)->void:
	var resource_state: ResourceState = resource.template.get_state(new_state)
	if resource_state == null:
		return
	set_cell(resource.layer, resource.position, resource_state.source_id, resource_state.altas_cords, resource_state.alternative_tile)
