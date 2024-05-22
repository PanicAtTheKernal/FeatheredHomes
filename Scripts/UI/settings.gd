extends Control

class_name settings

@onready 
var music_bus_id: int = AudioServer.get_bus_index("Music")
@onready
var sound_bus_id: int = AudioServer.get_bus_index("SFX")
@onready
var ambiance_bus_id: int = AudioServer.get_bus_index("Ambiance")
@onready 
var sound_value: Label = %SoundValue
@onready
var music_value: Label = %MusicValue
@onready 
var music_slider: HSlider = %MusicSlider
@onready 
var sound_slider: HSlider = %SoundSlider

signal clear_lines

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_player_settings()

func _on_close_button_pressed() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or InputEventScreenDrag:
		music_slider.focus_mode = Control.FOCUS_ALL
		sound_slider.focus_mode = Control.FOCUS_ALL

func _load_player_settings() -> void:
	var music_volume = PlayerResourceManager.player_data.music_volume
	var sound_volume = PlayerResourceManager.player_data.sound_volume
	music_value.text = str(round(music_volume*100),"%")
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_volume))
	music_slider.value = music_volume
	sound_value.text = str(round(sound_volume*100),"%")
	AudioServer.set_bus_volume_db(sound_bus_id, linear_to_db(sound_volume))
	AudioServer.set_bus_volume_db(ambiance_bus_id, linear_to_db(sound_volume))
	sound_slider.value = sound_volume

func _on_music_slider_value_changed(value: float) -> void:
	music_value.text = str(round(value*100),"%")
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(value))
	PlayerResourceManager.player_data.music_volume = value
	PlayerResourceManager.save_player_data()

func _on_sound_slider_value_changed(value: float) -> void:
	sound_value.text = str(round(value*100),"%")
	AudioServer.set_bus_volume_db(sound_bus_id, linear_to_db(value))
	AudioServer.set_bus_volume_db(ambiance_bus_id, linear_to_db(value))
	PlayerResourceManager.player_data.sound_volume = value
	PlayerResourceManager.save_player_data()	


func _on_check_button_toggled(toggled_on: bool) -> void:
	var partition_debug = get_tree().root.find_child("PartitionDebug", true, false)
	partition_debug.visible = toggled_on

func _on_navigation_toggled(toggled_on: bool) -> void:
	var birds = get_tree().root.find_child("Birds", true, false)
	for bird in birds.get_children():
		bird.nav_agent.debug_enabled = toggled_on
		clear_lines.emit()
	DebugGizmos.enabled = toggled_on

func _on_fps_toggled(toggled_on: bool) -> void:
	var debug_stats = get_tree().root.find_child("Debug", true, false)
	debug_stats.visible = toggled_on

func _on_wat_sound_sources_toggled(toggled_on: bool) -> void:
	var tile_map = get_tree().root.find_child("TileMap", true, false)
	for sound in tile_map.find_children("River?"):
		sound.visible = toggled_on
	for sound in tile_map.find_children("Water*"):
		sound.visible = toggled_on


func _on_win_sound_sources_toggled(toggled_on: bool) -> void:
	get_tree().root.find_child("Wind", true, false).visible = toggled_on


func _on_scroll_container_draw() -> void:
	# Adapt the content to screen size so the scrollable area is always on screen
	# There was a bug where the scroll bar will overflow from the screen, cutting off content from it
	var container: ScrollContainer = %ScrollContainer as ScrollContainer
	var margin: MarginContainer = $Panel/MarginContainer as MarginContainer
	var start_pos = container.global_position.y
	# The 40 is there because all of these contianers have hidden margins which cause the header to be pushed up
	var new_minium = DisplayServer.window_get_size_with_decorations().y - start_pos - margin.get_theme_constant("margin_bottom") - 40
	if container.custom_minimum_size.y != new_minium:
		container.custom_minimum_size.y = new_minium



func _on_button_pressed() -> void:
	var credit_dialog = Dialog.new().message("[color=#9f9f9f][u]Created By:[/u][/color]\nDaniel Kondabarov\n\n[color=#9f9f9f][u]Music\\Sound By:[/u][/color]\nIan Cecil Scott").header("Credits:").grand_notification()
	GlobalDialog.create(credit_dialog)
