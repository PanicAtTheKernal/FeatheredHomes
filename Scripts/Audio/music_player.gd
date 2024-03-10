extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#seek(stream.get_length()-10.0)

func _on_finished() -> void:
	var new_starting_point = snapped(randf() * stream.get_length(), 30.0)
	randomize()
	var music_tween = create_tween()
	music_tween.tween_property(self, "volume_db", -80, 0)
	play(new_starting_point)
	music_tween.tween_property(self, "volume_db", 0, 2)
