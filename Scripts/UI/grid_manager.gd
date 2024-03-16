extends GridContainer

@onready
var bird_stats: MarginContainer = $BirdStats
@onready
var description: MarginContainer = $Description
@onready
var traits: MarginContainer = $GeneralInfo
@onready
var general: MarginContainer = $Traits

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var window_size = get_window().size
	var half_size = size.x/2
	var margin = 32
	if window_size.x > Startup.NON_MOBLIE_SIZE:
		columns = 2
		bird_stats.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		bird_stats.custom_minimum_size.x = half_size-margin
		traits.custom_minimum_size.x = half_size
		general.custom_minimum_size.x = half_size
		bird_stats.add_theme_constant_override("margin_right", margin)
		description.add_theme_constant_override("margin_right", margin)
	else:
		columns = 1
		bird_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bird_stats.custom_minimum_size.x = 0
		traits.custom_minimum_size.x = 0
		general.custom_minimum_size.x = 0
		bird_stats.add_theme_constant_override("margin_right", 0)
		description.add_theme_constant_override("margin_right", 0)		
