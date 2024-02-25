extends Node

var enabled: bool = false

class DebugLine extends Node2D:
	var _line: Line2D
	
	func _init(colour: Color, width: float = 0.3) -> void:
		_line = Line2D.new()
		_line.default_color = colour
		_line.width = width
	
	func _ready() -> void:
		add_child(_line)
	
	func draw(points: Array[Vector2]):
		if not DebugGizmos.enabled:
			return
		_line.clear_points()
		for point in points:
			_line.add_point(point)
