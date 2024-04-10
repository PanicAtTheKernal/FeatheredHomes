extends Node

class_name Benchmark

var time:float = 0.0
var run: bool = false
var logger_key = {
	"type": Logger.LogType.GENERAL,
	"obj": "Benchmark"
}


func start_timer()->void:
	if not run:
		run = true
		time = 0.0

func end_timer()->void:
	if run:
		run = false
		Logger.print_debug(str("Time was ",time),logger_key)


func _on_timeout() -> void:
	if run:
		time += 0.1
