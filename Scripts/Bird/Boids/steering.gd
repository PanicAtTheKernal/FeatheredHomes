extends RefCounted

class_name Steering

var bird: Bird
var target: Vector2

func _init(_bird: Bird) -> void:
	bird = _bird
	target = Vector2.ZERO

# Abstract in name only
func calculate() -> Vector2:
	return target
