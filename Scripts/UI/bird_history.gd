extends Control

class_name BirdLog

@onready
var list: ItemList = %ItemList
var dragging: bool


var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "BirdLog"
}

class ListItem:
	var text: String
	var icon: Texture2D
	
	func _init() -> void:
		pass
	
	func set_name(new_name: String) -> ListItem:
		self.text = new_name
		return self
		
	func set_icon(new_icon: Texture2D) -> ListItem:
		self.icon = new_icon
		return self

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	dragging = false
	setup_list(BirdResourceManager.get_bird_list_items())
	BirdResourceManager.new_bird_added.connect(_on_new_bird)

func _process(delta)->void:
	var window_size = get_window().size
	#var empty_space = list.size.x - (floor(list.size.x/list.fixed_column_width)) 
	#margin.add_theme_constant_override("margin_left", empty_space/2)
	#var center_size = list.get_parent_area_size()
	#var i = list.fixed_column_width * round(window_size.x/list.fixed_column_width)
	#list.custom_minimum_size.x = list.fixed_column_width * round(window_size.x/list.fixed_column_width)
	#list.custom_minimum_size.y = list.get_parent_area_size().y

func _on_close_button_pressed()->void:
	hide()

func _on_new_bird()->void:
	setup_list(BirdResourceManager.get_bird_list_items())
	Logger.print_debug(("Updated bird history"), logger_key)

func setup_list(items: Array[ListItem])->void:
	Logger.print_debug("Setting up list", logger_key)
	list.clear()
	for item in items:
		list.add_item(item.text, item.icon)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		dragging = true
		var container: VScrollBar = list.get_v_scroll_bar()
		var max = container.max_value
		var min = container.min_value
		var new_value = container.value - event.relative.y
		container.value = clamp(new_value, min, max)
	else:
		dragging = false

func _on_item_list_item_selected(index: int)->void:
	await get_tree().create_timer(0.2).timeout
	if dragging:
		return
	var bird_info: BirdInfo = BirdResourceManager.get_bird(index)
	list.deselect(index)
	get_tree().call_group("BirdStat", "show")	
	get_tree().call_group("BirdStat", "load_new_bird", bird_info)
