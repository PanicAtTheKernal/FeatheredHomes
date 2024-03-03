extends AnimatedSprite2D

class_name BirdAnimation

var state: String = "default"
var animation_to_play: String = "default"
var finished: String = "default"
var logger_key = {
	"type": Logger.LogType.ANIMATION,
	"obj": "BirdAnimation"
}

signal animation_group_finished

func _wait_for_animation()->void:
	if not sprite_frames.get_animation_loop(animation) and frame_progress < 1.0:
		await animation_finished
	#stop()

func play_walking_animation():
	if animation == "Walking": return
	await _wait_for_animation()
	animation_group_finished.emit()
	play("Walking")
	Logger.print_debug("Playing Walking", logger_key)


func play_flying_animation():
	if animation == "Take-off" or animation == "Flight": return
	await _wait_for_animation()
	play("Take-off")
	Logger.print_debug("0: Playing Take-off", logger_key)
	await animation_finished
	animation_group_finished.emit()
	play("Flight")
	Logger.print_debug("0: Playing Flight", logger_key)
	

func play_take_off_animation():
	if animation == "Take-off" or animation == "Flight": return
	await _wait_for_animation()
	play_backwards("Take-off")
	Logger.print_debug("Playing Landing", logger_key)
	await animation_finished
	animation_group_finished.emit()


func play_landing_animation():
	if animation != "Flight": return
	await _wait_for_animation()
	play_backwards("Take-off")
	Logger.print_debug("Playing Landing", logger_key)
	await animation_finished
	animation_group_finished.emit()
	finished = "landing"
	play("default")


func play_swimming_animation():
	if animation == "defualt": return
	await _wait_for_animation()
	play("default")
	Logger.print_debug("Playing default", logger_key)
	animation_group_finished.emit()


func play_eating_animation():
	if animation == "Eating": return
	await _wait_for_animation()
	play("Eating", 0.5)
	Logger.print_debug("Playing Eating", logger_key)
	await animation_finished
	animation_group_finished.emit()
	finished = "eating"
	play("default")

func play_dance_animation():
	if animation == "Dance": return
	await _wait_for_animation()
	play("Dance", 0.5)
	Logger.print_debug("Playing Mating Dance", logger_key)
	await animation_finished
	animation_group_finished.emit()
	play("default")
	finished = "dancing"

# func update_state(new_state):
# 	if (state != new_state):

# 		stop()
# 		state = new_state
# 		Logger.print_debug("New state "+new_state, logger_key)

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
