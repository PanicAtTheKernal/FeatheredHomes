extends Resource
class_name ProtoFood

@export
var food_resouces: Array[FoodResouce]

func find_resource_by_id(altas_cords: Vector2i):
	for resource in food_resouces:
		if resource.get_atlas_cords().find(altas_cords) != -1:
			return resource
