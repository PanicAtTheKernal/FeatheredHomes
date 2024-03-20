extends SoundEffect

func _process(_delta: float) -> void:
	var half = player_cam.MAX_ZOOM - player_cam.MIN_ZOOM
	var volume
	if player_cam.zoom.x < half:
		volume = _zoom_to_linear(player_cam.zoom)		
	else:
		volume = 1 - _zoom_to_linear(player_cam.zoom)
	audio_player.volume_db = linear_to_db(volume)
