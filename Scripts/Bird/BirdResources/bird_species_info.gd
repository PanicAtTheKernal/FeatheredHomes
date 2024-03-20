extends Resource

class_name BirdSpecies

@export_group("GeneralBirdInfo")
@export
var name: String
@export_range(0.1, 11.0)
var size: float
@export
var diet: String
@export
var sound: String
@export
var nest_type: String
@export_range(20, 30)
var max_age: int
@export
var is_predator: bool

@export 
var animations: SpriteFrames

@export_group("Navigation")
@export_range(100, 10000) 
var max_stamina: float 
@export_range(100, 10000) 
var stamina: float
@export_range(0.2, 0.9)
var threshold: float

@export_group("Ground")
@export_range(5.0, 300.0)
var ground_cost: float
@export
var can_swim: bool = false
@export
var can_fly: bool = true
@export_range(4.0, 48.0)
var ground_max_distance: float

@export_group("Flight")
@export_range(0.1, 500.0)
var take_off_cost: float
@export_range(5.0, 300.0) 
var flight_cost: float
#Anything above the maximimum will trigger the migration action
@export_range(24.0, 64.0)
var flight_max_distance: float

@export_group("Traits")
@export
var preen: bool
@export
var takes_dust_baths: bool
@export
var does_sunbathing: bool
@export
var coparent: bool
@export
var male_single_parent: bool
@export
var female_single_parent: bool

func copy()->BirdSpecies:
	var species_copy = BirdSpecies.new()
	species_copy.name = name
	species_copy.size = size
	species_copy.diet = diet
	species_copy.sound = sound
	species_copy.nest_type = nest_type
	species_copy.max_age = max_age
	species_copy.is_predator = is_predator
	species_copy.animations = animations
	species_copy.max_stamina = max_stamina
	species_copy.stamina = stamina
	species_copy.threshold = threshold
	species_copy.ground_cost = ground_cost
	species_copy.can_swim = can_swim
	species_copy.can_fly = can_fly
	species_copy.ground_max_distance = ground_max_distance
	species_copy.take_off_cost = take_off_cost
	species_copy.flight_cost = flight_cost
	species_copy.flight_max_distance = flight_max_distance
	species_copy.preen = preen
	species_copy.takes_dust_baths = takes_dust_baths
	species_copy.does_sunbathing = does_sunbathing
	species_copy.coparent = coparent
	species_copy.male_single_parent = male_single_parent
	species_copy.female_single_parent = female_single_parent
	return species_copy
