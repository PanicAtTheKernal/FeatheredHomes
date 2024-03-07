extends Control

@onready 
var music_bus_id: int = AudioServer.get_bus_index("Music")
@onready
var sound_bus_id: int = AudioServer.get_bus_index("SFX")
@onready
var ambiance_bus_id: int = AudioServer.get_bus_index("Ambiance")
@onready 
var sound_value: Label = $Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/Sound/SoundValue
@onready
var music_value: Label = %MusicValue
@onready 
var music_slider: HSlider = %MusicSlider
@onready 
var sound_slider: HSlider = %SoundSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_player_settings()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()

func _load_player_settings() -> void:
	var music_volume = PlayerResourceManager.player_data.music_volume
	var sound_volume = PlayerResourceManager.player_data.sound_volume*1.5
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
	PlayerResourceManager.player_data.sound_volume = value*1.5
	PlayerResourceManager.save_player_data()	
