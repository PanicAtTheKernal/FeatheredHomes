extends MarginContainer

class_name AssetLoaders

@export
var node_to_hide: Control

@onready
var item_list: ItemList = $ItemList


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_list.clear()
	var bird_list_items: Array[BirdLog.ListItem] = []
	for collected_bird in BirdResourceManager.birds:
		var new_list_item = BirdLog.ListItem.new()
		var gender = "(M) " if collected_bird.gender == "male" else "(F) "
		new_list_item.set_name(str(gender,collected_bird.species.name))
		new_list_item.set_icon(collected_bird.species.animations.get_frame_texture("default", 0))	
		item_list.add_item(new_list_item.text, new_list_item.icon)

func _on_item_list_item_selected(index: int) -> void:
	node_to_hide.hide()
	get_tree().call_group("PlayerCamera", "turn_on_movement")
	var bird_info = BirdResourceManager.birds[index]
	var bird = BirdResourceManager.bird_manager.create_bird(bird_info)
	BirdResourceManager.bird_manager.add_bird(bird)

