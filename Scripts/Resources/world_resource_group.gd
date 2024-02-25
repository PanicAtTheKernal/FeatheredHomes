extends Resource

class_name WorldResourceTemplateGroup

@export
var group_name: String
@export
var resource_templates: Array[WorldResourceTemplate]

# Build a dictionary where the key is the atlas cord and the value is the WorldResourceTemplate
func get_resources()->Dictionary:
	var resources: Dictionary = {}
	for resource_template in resource_templates:
		for atlas_cords in resource_template.get_atlas_cords():
			resources[atlas_cords] = resource_template
	return resources

func get_states()->Array:
	# Assuming each each template has the same amount of states
	return resource_templates[0].get_states()
