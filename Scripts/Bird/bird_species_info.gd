extends Resource

class_name BirdSpecies

@export_group("GeneralBirdInfo")
@export
var bird_name: String

@export 
var bird_animations: SpriteFrames

@export_group("Navigation")
@export_range(0, 200) 
var bird_range: float
@export_range(100, 100000) 
var bird_max_stamina: float 
@export_range(100, 100000) 
var bird_stamina: float

@export_group("Ground")
@export_range(5.0, 300.0)
var bird_ground_cost: float
@export
var can_bird_swim: bool = false
@export
var can_bird_fly: bool = true
@export_range(4.0, 48.0)
var bird_ground_max_distance: float

@export_group("Flight")
@export_range(0.1, 500.0)
var bird_take_off_cost: float
@export_range(5.0, 300.0) 
var bird_flight_cost: float
#Anything above the maximimum will trigger the migration action
@export_range(24.0, 64.0)
var bird_flight_max_distance: float

@export_group("Traits")
@export
var bird_traits: Array[String]
