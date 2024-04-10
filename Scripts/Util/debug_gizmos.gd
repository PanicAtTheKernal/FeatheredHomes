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
		_line.clear_points()
		if not DebugGizmos.enabled:
			_line.clear_points()
			return
		for point in points:
			_line.add_point(point)
	
	func _clear_lines():
		_line.clear_points()
