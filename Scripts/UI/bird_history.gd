extends Control

@onready
var list: ItemList = $Panel/ItemList

var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "BirdHistory"
}

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	setup_list(BirdResourceManager.get_bird_list_items())
	BirdResourceManager.new_bird.connect(_on_new_bird)

func _process(delta)->void:
	pass


func _on_item_list_item_clicked(index, at_position, mouse_button_index)->void:
	print("You clicked on "+list.get_item_text(index))

func _on_close_button_pressed()->void:
	hide()

func _on_new_bird(new_bird: BirdInfo)->void:
	var new_item = str(new_bird.species.bird_name)
	list.add_item(new_item)
	Logger.print_debug(("New bird added to bird history '"+new_item+"'"), logger_key)

func setup_list(items: PackedStringArray)->void:
	Logger.print_debug("Setting up list", logger_key)
	list.clear()
	for item in items:
		list.add_item(item)
