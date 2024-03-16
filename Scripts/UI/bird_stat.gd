extends Control

@onready
var panel: PanelContainer = %Panel
@onready
var image: TextureRect = %BirdImage
@onready
var bird_name_label: Label = %BirdNameData
@onready
var date_found_label: Label = %DateFoundData
@onready
var status_label: Label = %StatusData
@onready
var new_frame_timer: Timer = %NewFrameTimer
@onready
var description: RichTextLabel = %DescriptionData
@onready
var family_label: Label = %FamilyData
@onready
var scientific_label: Label = %ScientificData
@onready
var gender_label: Label = %GenderData
@onready
var diet_label: Label = %DietData
@onready
var fly_label: Label = %FlyData
@onready
var swim_label: Label = %SwimData
@onready
var cleaning_label: Label = %CleaningMethodsData
@onready
var current_stamina: Label = %CurrentStaminaData
@onready
var age_label: Label = %AgeData
@onready
var parenting_style_label: Label = %ParentingStyleData
@onready
var predator_label: Label = %PredatorData

@export
var default_frames: SpriteFrames

var bird_frames: SpriteFrames
var anim_names: PackedStringArray
var current_anim_name: String
var current_anim_index: int
var current_frame_index: int
var max_frames: int
var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "BirdStat"
}

func _ready()->void:
	if not is_visible_in_tree():
		new_frame_timer.stop()

func _process(_delta: float) -> void:
	var window = get_window()
	if window.size.x > Startup.NON_MOBLIE_SIZE:
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.custom_minimum_size.x = 960
	else:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = 0

func load_new_bird(bird: BirdInfo)->void:
	var date_dict = Time.get_datetime_dict_from_datetime_string(bird.date_found, false)
	var date_found = str(date_dict.get("day"),"/",date_dict.get("month"),"/",date_dict.get("year"))
	# Stats
	bird_name_label.text = bird.species.name
	status_label.text = bird.status
	age_label.text = bird.age_status
	# General
	family_label.text = bird.family
	scientific_label.text = bird.scientific_name
	gender_label.text = bird.gender
	diet_label.text = bird.species.diet
	date_found_label.text = date_found
	# Description
	description.text = bird.description
	# Traits
	fly_label.text = "Yes" if bird.species.can_fly else "No"
	swim_label.text = "Yes" if bird.species.can_swim else "No"
	predator_label.text = "Yes" if bird.species.is_predator else "No"
	_build_parenting_label(bird)
	_build_cleaning_label(bird)
	current_stamina.text = str(snapped(bird.species.stamina/bird.species.max_stamina * 100,0.1),"%")
	if bird.status != "Not generated":
		_load_image(bird.species.animations)
	else:
		Logger.print_debug("Bird isn't generated, using image placeholder", logger_key)
		_load_image(default_frames)
	Logger.print_debug(str("Updated UI with ",bird.species.name), logger_key)
	
	
func _build_cleaning_label(bird: BirdInfo)->void:
	var cleaning_methods: String = ""
	if bird.species.preen:
		cleaning_methods += "Preening, "
	if bird.species.takes_dust_baths:
		cleaning_methods += "Dust Baths, "
	if bird.species.does_sunbathing:
		cleaning_methods += "Sunbathing, "
	cleaning_label.text = cleaning_methods.trim_suffix(", ")

func _build_parenting_label(bird: BirdInfo)->void:
	var parenting_style: String = ""
	if bird.species.female_single_parent:
		parenting_style += "Single Mother"
	elif bird.species.male_single_parent:
		parenting_style += "Single Father"
	elif bird.species.coparent:
		parenting_style += "Both Parents"
	parenting_style_label.text = parenting_style.trim_suffix(", ")

func _load_image(frames: SpriteFrames)->void:
	if len(frames.get_animation_names()) > 0:
		bird_frames = frames
		anim_names = bird_frames.get_animation_names()
		current_anim_index = 0
		current_anim_name = anim_names[current_anim_index]
		current_frame_index = 0
		max_frames = bird_frames.get_frame_count(current_anim_name)-1
		image.texture = bird_frames.get_frame_texture(current_anim_name, current_frame_index)	
		new_frame_timer.start()


func _on_new_frame_timer_timeout()->void:
	# Loop through frames of the bird different animations
	image.texture = bird_frames.get_frame_texture(current_anim_name, current_frame_index)
	if current_frame_index == max_frames:
		current_anim_index = (current_anim_index + 1) % len(anim_names)
		current_anim_name = anim_names[current_anim_index]
		current_frame_index = 0
		max_frames = bird_frames.get_frame_count(current_anim_name)-1
	else:
		current_frame_index += 1


func _on_close_button_pressed()->void:
	new_frame_timer.stop()
	hide()

func _on_scroll_container_draw() -> void:
	# Adapt the content to screen size so the scrollable area is always on screen
	# There was a bug where the scroll bar will overflow from the screen, cutting off content from it
	var container: ScrollContainer = $Panel/MarginContainer/Content/ScrollContainer as ScrollContainer
	var margin: MarginContainer = $Panel/MarginContainer as MarginContainer
	var start_pos = container.global_position.y
	var new_minium = DisplayServer.window_get_size_with_decorations().y - start_pos - margin.get_theme_constant("margin_bottom")
	if container.custom_minimum_size.y != new_minium:
		container.custom_minimum_size.y = new_minium

func _input(event: InputEvent) -> void:
	# There is a bug where the scroll event is inconsistent with this constainer,
	# this adds a fix using the screen drag event instead
	if event is InputEventScreenDrag:
		var container: ScrollContainer = $Panel/MarginContainer/Content/ScrollContainer as ScrollContainer
		var max_v = container.get_v_scroll_bar().max_value
		var min_v = container.get_v_scroll_bar().min_value
		var new_value = container.get_v_scroll_bar().value - event.relative.y
		container.get_v_scroll_bar().value = clamp(new_value, min_v, max_v)
