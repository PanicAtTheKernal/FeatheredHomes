extends Node

class_name WorldNavigation

@export
var tile_map: TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_server()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _setup_server():
	pass
	#for i in range(tile_map.get_layers_count()):
	#	var map: RID = tile_map.get_navigation_map(i)
	#	NavigationServer2D.map_set_active(map, true)
	#	NavigationServer2D.map_set_cell_size(map, 0.25)
	#	NavigationServer2D.map_force_update(map)
	#print(NavigationServer2D.get_maps())
	#for map in NavigationServer2D.get_maps():
	#	print(NavigationServer2D.map_is_active(map))
