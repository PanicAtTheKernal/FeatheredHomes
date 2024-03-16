extends Node2D

class_name SoundEffect

@export_range(10, 1000)
var max_distance: float
@export
var sound: AudioStreamMP3
@export
var player_cam: PlayerCam

@export
var audio_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_player.max_distance = max_distance
	audio_player.stream = sound
	audio_player.play()

func _draw() -> void:
	draw_circle(Vector2(0,0), max_distance/2, Color.DEEP_SKY_BLUE)
	draw_circle(Vector2(0,0), 2.0, Color.DARK_VIOLET)

func _process(_delta: float) -> void:
	var volume = _zoom_to_linear(player_cam.zoom)
	audio_player.volume_db = linear_to_db(volume)

func _zoom_to_linear(value: Vector2) -> float:
	var zoom = value.x
	return ((zoom - player_cam.MIN_ZOOM) / (player_cam.MAX_ZOOM - player_cam.MIN_ZOOM))
