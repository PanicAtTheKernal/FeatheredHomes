extends Node

class_name BirdAssetImporter

signal bird_imported

var bird_supa_data: Dictionary 
var bird: BirdInfo
var logger_key = {
	"type": Logger.LogType.DATABASE,
	"obj": "BirdAssetImporter"
}

func _init(bird_data: Dictionary, gender:String="Unisex")->void:
	bird = BirdInfo.new()
	bird.species = BirdSpecies.new()
	if gender != "Unisex":
		bird.gender = gender
	bird_supa_data = bird_data

func import()->BirdInfo:
	_build_info()
	_build_species()
	await _build_diet()
	await _build_shape()
	await _build_image()
	bird.status = BirdInfo.StatusTypes.GENERATED
	return bird

func _build_species()->void:
	var simulation_info = bird_supa_data.get("birdSimulationInfo") as Dictionary
	bird.species.name = (bird_supa_data["birdName"] as String).capitalize()
	bird.species.ground_cost = 5
	bird.species.can_swim = simulation_info.get("canSwim")
	bird.species.can_fly = simulation_info.get("canFly")
	bird.species.take_off_cost = 1
	bird.species.flight_cost = 10
	bird.species.preen = simulation_info.get("preen")
	bird.species.takes_dust_baths = simulation_info.get("takesDustBaths")
	bird.species.does_sunbathing = simulation_info.get("doesSunbathing")	

func _build_info()->void:
	bird.description = bird_supa_data.get("birdDescription")
	bird.family = (bird_supa_data.get("birdFamily") as String).capitalize()
	bird.scientific_name = (bird_supa_data.get("birdScientificName") as String).capitalize()
	bird.unisex = bird_supa_data["birdUnisex"]

func _build_shape()->void:
	var shape = await Database.fetch_shape(bird_supa_data["birdShapeId"])
	bird.species.size = shape["BirdShapeSize"]

func _build_diet()->void:
	bird.species.diet = await Database.fetch_diet_name(bird_supa_data["dietId"])

func _build_image()->void:
	var shape = await Database.fetch_shape(bird_supa_data["birdShapeId"])
	var url = bird_supa_data["birdImages"]["image"] if bird_supa_data["birdUnisex"] else bird_supa_data["birdImages"][bird.gender]
	var animation_builder = AnimationBuilder.new(shape["BirdShapeAnimationTemplate"], url)
	add_child(animation_builder)
	bird.species.animations = await animation_builder.build()
	animation_builder.queue_free()
