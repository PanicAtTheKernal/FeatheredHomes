extends ItemList

class_name AssetLoaders

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear()
	var bird_list_items: Array[BirdLog.ListItem] = []
	for collected_bird in BirdResourceManager.birds:
		var new_list_item = BirdLog.ListItem.new()
		var gender = "(M) " if collected_bird.gender == "male" else "(F) "
		new_list_item.set_name(str(gender,collected_bird.species.name))
		new_list_item.set_icon(collected_bird.species.animations.get_frame_texture("default", 0))	
		add_item(new_list_item.text, new_list_item.icon)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_selected(index: int) -> void:
	var bird_info = BirdResourceManager.birds[index]
	var bird = BirdResourceManager.bird_manager.create_bird(bird_info)
	BirdResourceManager.bird_manager.add_bird(bird)
