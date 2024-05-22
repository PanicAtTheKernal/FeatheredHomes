extends Node

class_name CollectedBirds

var collected_birds: Array[BirdInfo] = []
var collected_birds_item_list: Array[BirdLog.ListItem]

signal collected_birds_list_updated

func add(collected_bird: BirdInfo) -> void:
	collected_birds.push_back(collected_bird)
	collected_birds_list_updated.emit()	

	
func get_list_items()->Array[BirdLog.ListItem]:
	var bird_list_items: Array[BirdLog.ListItem] = []
	for collected_bird in collected_birds:
		var new_list_item = BirdLog.ListItem.new()
		new_list_item.set_name(str("-",collected_bird.species.name))
		new_list_item.set_icon(collected_bird.species.animations.get_frame_texture("default", 0))	
		bird_list_items.push_back(new_list_item)
	return bird_list_items

func remove_bird(dead_bird:BirdInfo)->void:
	collected_birds.erase(dead_bird)
	collected_birds_list_updated.emit()

func get_bird(index: int)->BirdInfo:
	if index < 0 and index > collected_birds.size():
		return null
	return collected_birds[index]

