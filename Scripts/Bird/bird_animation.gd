extends AnimatedSprite2D

var state: String = "Ground"
var animation_to_play: String = "default"

func _process(delta):
	if not is_playing():
		play(animation_to_play)


func _on_bird_change_state(new_state: String, should_flip_h: bool):
	#if should_flip_h == null:
	#	flip_h = 
	print(should_flip_h, flip_h)
	if state == "Ground":
		animation_to_play = "default"
	elif state == "Water":
		animation_to_play = "default"
	elif state == "Flying":
		flip_h = should_flip_h
		print(should_flip_h, flip_h)
		animation_to_play = "Take-off"
		print(is_playing())
		play("Flight")
	state = new_state


func _on_animation_finished():
	# Make sure the take-off animation finished
	if animation == "Take-off":
		animation_to_play = "Flight"
