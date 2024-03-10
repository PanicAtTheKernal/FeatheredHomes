extends Resource

class_name BirdInfo

enum StatusTypes {
	NOT_GENERATED,
	GENERATED,
	TEEN,
	YOUNG_ADULT,
	ADULT,
	ELDER,
	DEAD
}

@export
var date_found: String
@export
var id: int
@export
var status: String
@export
var age_status: String
@export
var species: BirdSpecies
@export
var description: String
@export
var family: String
@export
var scientific_name: String
@export
var gender: String
@export
var unisex: bool
@export_range(0.1, 10.0)
var version: float

var status_messages: Dictionary = {
	StatusTypes.NOT_GENERATED: "Not generated",
	StatusTypes.GENERATED: "Generated",
	StatusTypes.DEAD: "Dead",
	StatusTypes.TEEN: "Teen",
	StatusTypes.YOUNG_ADULT: "Young Adult",
	StatusTypes.ADULT: "Adult",
	StatusTypes.ELDER: "Elder",
}

func _init():
	date_found = Time.get_datetime_string_from_system()
	id = _create_id()
	status = "Not generated"
	age_status = "Teen"
	
func _create_id()->int:
	var date_dict = Time.get_datetime_dict_from_datetime_string(date_found, false)
	var date = str(date_dict.get("month"),date_dict.get("day"),date_dict.get("year"))
	var time = str(date_dict.get("hour"), date_dict.get("minute"))
	return int((date+time))
	
func create_unique_id()->int:
	var date_dict = Time.get_datetime_dict_from_system()
	var date = str(date_dict.get("month"),date_dict.get("day"),date_dict.get("year"))
	var time = str(date_dict.get("hour"), date_dict.get("minute"))
	return int(Time.get_ticks_usec())
	

func set_bird_species(species: BirdSpecies):
	self.species = species
