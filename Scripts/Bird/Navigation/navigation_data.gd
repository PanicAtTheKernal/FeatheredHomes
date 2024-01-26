extends Task

class_name NavigationData

@export
var nav_agent: NavigationAgent2D
@export
var character_body: CharacterBody2D
@export
var animated_sprite: AnimatedSprite2D
@export
var navigation_timer: Timer
@export
var bird_species_info: BirdSpecies
@export
var calulate_distance: CalculateDistance

func run():
	get_child(0).run()
	super.running()
	
func child_success():
	super.success()

func child_fail():
	super.fail()
	
func child_running():
	super.running()
	
func start():
	bird_species_info = data["species"]
	super.start()
