extends Control

class_name Dialog

const dialog_content_scene: PackedScene = preload("res://Scripts/UI/Componets/Dialog/DialogContent.tscn")

var dialog: Control
var dialog_text : RichTextLabel
var heading_text : Header
var panel: PanelContainer
var ok_button: Button
var sound_player: AudioStreamPlayer
var offset: float = 0.0
var audio_stream: AudioStream

func _init() -> void:
	dialog = dialog_content_scene.instantiate()
	dialog_text = dialog.find_child("Text", true, false)
	heading_text = dialog.find_child("Header", true, false)
	panel = dialog.find_child("Panel", true, false)
	ok_button = dialog.find_child("OkButton", true, false)

func _ready()->void:
	sound_player = get_tree().root.find_child("NotificationPlayer", true, false)
	ok_button.pressed.connect(_on_ok_button_pressed)
	add_child(dialog)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hide()
	display()

func _process(_delta: float) -> void:
	var window = get_window()
	if window.size.x > Startup.NON_MOBLIE_SIZE:
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.custom_minimum_size.x = 960
	else:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = 0

func display()->void:
	if sound_player != null and audio_stream != null:
		sound_player.stream = audio_stream
		sound_player.play(offset)
	var time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	await get_tree().create_timer(time_delay).timeout
	show()
	
func minimum_height(new_y: int)->Dialog:
	panel.custom_minimum_size.y = new_y
	return self

func message(_message: String) -> Dialog:
	dialog_text.text = _message
	return self

func sound(_sound: AudioStream, _offset: float = 0) -> Dialog:
	audio_stream = _sound
	offset = _offset
	return self

func grand_notification() -> Dialog:
	return sound(ResourceFiles.grand_notification, 0)

func regular_notification() -> Dialog:
	return sound(ResourceFiles.standard_notification, 0.85)

func header(_heading: String) -> Dialog:
	heading_text.text = _heading
	return self

func fit_content(_fit_content: bool) -> Dialog:
	dialog_text.fit_content = _fit_content
	return self

func _on_ok_button_pressed()->void:
	get_tree().call_group("PlayerCamera", "turn_on_movement")
	queue_free()
