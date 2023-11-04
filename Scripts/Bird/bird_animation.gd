extends AnimatedSprite2D

var state: String = "Ground"
var animation_to_play: String = "default"

func _process(delta):
	play(animation_to_play)


func _on_bird_change_state(new_state: String):
	if state == "Ground":
		animation_to_play = "default"
	elif state == "Water":
		animation_to_play = "default"
	elif state == "Flying":
		animation_to_play = "Take-off"
		print(is_playing())
		play("Flight")
	state = new_state


func _on_animation_finished():
	animation_to_play = "Flight"
