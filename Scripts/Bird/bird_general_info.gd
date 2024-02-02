extends Resource

class_name BirdInfo

@export
var date_found: String
@export
var id: int
@export
var species: BirdSpecies

func _init():
	date_found = Time.get_datetime_string_from_system()
	id = _create_id()
	
func _create_id()->int:
	var date_dict = Time.get_datetime_dict_from_datetime_string(date_found, false)
	var date = str(date_dict.get("month"),date_dict.get("day"),date_dict.get("year"))
	var time = str(date_dict.get("hour"), date_dict.get("minute"))
	return int((date+time))
	
func set_bird_species(species: BirdSpecies):
	self.species = species
