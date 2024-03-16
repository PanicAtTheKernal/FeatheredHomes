extends Node2D

@onready
var tilemap:TileMapManager = %TileMap
@export
var font: Font

func _draw() -> void:
	for i in range(tilemap.partition_size):
		for j in range(tilemap.partition_size):
			var partition = Rect2(i*tilemap.partition_width*tilemap.TILE_SIZE, j*tilemap.partition_height*tilemap.TILE_SIZE, tilemap.partition_width*tilemap.TILE_SIZE, tilemap.partition_height*tilemap.TILE_SIZE)
			var string_pos = Vector2((i*tilemap.partition_width*tilemap.TILE_SIZE)+((tilemap.partition_width*tilemap.TILE_SIZE)/2)-8,(j*tilemap.partition_height*tilemap.TILE_SIZE)+((tilemap.partition_height*tilemap.TILE_SIZE)/2)-8)
			draw_rect(partition, Color.DARK_BLUE, false, 1)
			draw_string(font, string_pos, str("(",i,",",j,")"), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.BLACK)
