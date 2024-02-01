extends AnimatedSprite2D

var state: String = "default"
var animation_to_play: String = "default"
signal play_new_animation

func _on_bird_change_state(new_state: String, should_flip_h: bool):
	# Only play a new animation when the new state is different than the current state
	if (state != new_state):
		stop()
		state = new_state	
		flip_h = should_flip_h
		play_new_animation.emit()

func _on_animation_finished():
	# Make sure the take-off animation finished
	var anime = animation
	match anime:
		"Take-off":
			animation_to_play = "Flight"
		"Eating":
			animation_to_play = "default"
	play(animation_to_play)

func _on_play_new_animation():
	match state:
		"Ground":
			animation_to_play = "Walking"
		"Water":
			animation_to_play = "default"
		"Flying":
			animation_to_play = "Take-off"
		"Eat":
			animation_to_play = "Eating"
		"default":
			animation_to_play = "default"
	print(animation_to_play)
	play(animation_to_play)
