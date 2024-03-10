extends SoundEffect

func _process(delta: float) -> void:
	var volume = 1 - _zoom_to_linear(player_cam.zoom)
	audio_player.volume_db = linear_to_db(volume)
