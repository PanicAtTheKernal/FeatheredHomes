extends Resource

class_name PlayerData

@export
var birds: Array[BirdState]
@export_range(0.1, 10.0)
var version: float

@export_category("Audio")
@export
var music_volume: float
@export
var sound_volume: float
