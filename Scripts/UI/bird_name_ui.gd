extends Label

var scroll_timer: Timer
var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "BirdNameUI"
}

var max_font_size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_font_size = get_theme_font_size("font_size")
	
func _process(delta: float) -> void:
	if has_theme_font_size_override("font_size"):
		remove_theme_font_size_override("font_size")
	var new_font_size = min(get_visible_characters_count(), max_font_size)
	add_theme_font_size_override("font_size",  new_font_size)
	
func get_visible_characters_count()->int:
	# Adding the an offset since the font size and font width are different values
	#return floor((size.x+(get_total_character_count()*16))/get_total_character_count())
	return round((size.x)/(get_total_character_count())+(0.4*get_total_character_count()))
