extends Node

class_name BirdAssetImporter

signal bird_imported

var bird_name: String
var bird: BirdSpecies

func _init(bird_name: String)->void:
	self.bird_name = bird_name
	bird = BirdSpecies.new()
	bird.bird_name = bird_name
	
func import()->void:
	await get_tree().create_timer(1).timeout
	bird_imported.emit()

func get_bird()->BirdSpecies:
	return bird
