extends AnimatedSprite2D

class_name BirdAnimation

var state: String = "default"
var animation_to_play: String = "default"
var logger_key = {
	"type": Logger.LogType.ANIMATION,
	"obj": "BirdAnimation"
}

func play_animation(new_state: String):
	# Only play a new animation when the new state is different than the current state
	if (state != new_state):
		stop()
		state = new_state	
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
		_:
			Logger.print_debug("Can't play animation"+state, logger_key)
	Logger.print_debug("[Current Animation] "+animation_to_play, logger_key)
	play(animation_to_play)

func play_walking_animation():
	if state != "Ground": return
	play("Walking")
	Logger.print_debug("Playing Walking", logger_key)

func play_flying_animation():
	if state != "Flying" or animation == "Flight": return
	play("Take-off")
	Logger.print_debug("Playing Take-off", logger_key)
	await animation_finished
	play("Flight")
	Logger.print_debug("Playing Flight", logger_key)

func play_landing_animation():
	if state != "Flying" or animation != "Flight": return
	play_backwards("Take-off")
	Logger.print_debug("Playing Take-off", logger_key)
	await animation_finished
	play("default")

func play_swimming_animation():
	if state != "Water": return
	play("default")
	Logger.print_debug("Playing default", logger_key)

func play_eating_animation():
	if state != "Eat": return
	play("Eating")
	Logger.print_debug("Playing Eating", logger_key)	

func update_state(new_state):
	if (state != new_state):
		stop()
		state = new_state
		Logger.print_debug("New state "+new_state, logger_key)

# func _on_play_new_animation():
# 	match state:
# 		"Ground":
# 			animation_to_play = "Walking"
# 		"Water":
# 			animation_to_play = "default"
# 		"Flying":
# 			animation_to_play = "Take-off"
# 		"Eat":
# 			animation_to_play = "Eating"
# 		"default":
# 			animation_to_play = "default"
# 	Logger.print_debug("[Current Animation]"+animation_to_play, logger_key)
# 	play(animation_to_play)
