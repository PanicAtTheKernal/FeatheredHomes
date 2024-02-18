extends Control

@onready
var list: ItemList = %ItemList

var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "BirdHistory"
}

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	setup_list(BirdResourceManager.get_bird_list_items())
	BirdResourceManager.new_bird_added.connect(_on_new_bird)

func _process(delta)->void:
	pass

func _on_close_button_pressed()->void:
	hide()

func _on_new_bird()->void:
	setup_list(BirdResourceManager.get_bird_list_items())
	Logger.print_debug(("Updated bird history"), logger_key)

func setup_list(items: PackedStringArray)->void:
	Logger.print_debug("Setting up list", logger_key)
	list.clear()
	for item in items:
		list.add_item(item)


func _on_item_list_item_selected(index: int)->void:
	var bird_info: BirdInfo = BirdResourceManager.get_bird(index)
	list.deselect(index)
	get_tree().call_group("BirdStat", "show")	
	get_tree().call_group("BirdStat", "load_new_bird", bird_info)
