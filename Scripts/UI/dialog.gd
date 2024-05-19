extends Control

class_name Dialog

@onready 
var dialog_text : RichTextLabel = %Text
@onready
var heading_text : Header = %Header
@onready
var dialog: Control = $"."
@onready
var panel: PanelContainer = %Panel

func _ready()->void:
	dialog.visible = false

func _process(_delta: float) -> void:
	var window = get_window()
	if window.size.x > Startup.NON_MOBLIE_SIZE:
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.custom_minimum_size.x = 960
	else:
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.custom_minimum_size.x = 0

func display(message: String, heading: String = "Notice:",grand_sound: bool = false, fit_content: bool = true)->void:
	var sound_player: AudioStreamPlayer = get_tree().root.find_child("NotificationPlayer", true, false)
	var offset
	if grand_sound:
		sound_player.stream = Startup.grand_notification
		offset = 0
	else:
		sound_player.stream = Startup.standard_notification
		offset = 0.85
	sound_player.play(offset)
	var time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	await get_tree().create_timer(time_delay).timeout
	dialog.visible = true
	dialog_text.text = message
	dialog_text.fit_content = fit_content
	heading_text.text = heading
	
func increase_dialog()->void:
	panel.custom_minimum_size.y = 800

func _on_ok_button_pressed()->void:
	panel.custom_minimum_size.y = 200	
	dialog.visible = false
	get_tree().call_group("PlayerCamera", "turn_on_movement")
