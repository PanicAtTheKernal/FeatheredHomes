extends Resource

class_name BirdSpecies

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

@export_group("Flight")
@export_range(0.1, 500.0)
var bird_take_off_cost: float
@export_range(5.0, 300.0) 
var bird_flight_cost: float

@export_group("Traits")
@export
var bird_traits: Array[String]
