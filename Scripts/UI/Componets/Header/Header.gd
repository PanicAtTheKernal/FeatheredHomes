@tool

extends MarginContainer

class_name Header

@export
var is_close_button_showing: bool = false :
	set(value):
		if close_button != null:
			close_button.visible = value
		is_close_button_showing = value
@export
var node_to_close: CanvasItem
@export
var delete_node: bool = false
@export
var text: String = "Notice:":
	set(value):
		if header_label != null:
			header_label.text = str("[b]",value,"[/b]")
		text = value

@onready
var close_button: Button = %CloseButton
@onready
var header_label: RichTextLabel = %Notice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.visible = is_close_button_showing
	header_label.text = text
	close_button.pressed.connect(_close_node)

func _close_node():
	if delete_node and node_to_close != null:
		node_to_close.queue_free()
	elif node_to_close != null:
		node_to_close.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
