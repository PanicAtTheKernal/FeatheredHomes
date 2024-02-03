extends Control

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

func _ready():
	if not is_visible_in_tree():
		new_frame_timer.stop()

func load_new_bird(bird: BirdInfo)->void:
	var date_dict = Time.get_datetime_dict_from_datetime_string(bird.date_found, false)
	var date_found = str(date_dict.get("day"),"/",date_dict.get("month"),"/",date_dict.get("year"))
	bird_name_label.text = bird.species.bird_name
	date_found_label.text = date_found
	status_label.text = bird.get_status_message(bird.status)
	if bird.status != BirdInfo.StatusTypes.NOT_GENERATED:
		_load_image(bird.species.bird_animations)
	else:
		Logger.print_debug("Bird isn't generated, using image placeholder", logger_key)
		_load_image(default_frames)
	Logger.print_debug(str("Updated UI with ",bird.species.bird_name), logger_key)
	

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
