extends Node

class_name BirdAssetImporter

const MAX_STAMINA = 10000
const MIN_STAMINA = 500
const MAX_GROUND_DISTANCE = 10
const MIN_GROUND_DISTANCE = 4
const MAX_FLIGHT_DISTANCE = 30

signal bird_imported

var http_request: HTTPRequest
var auth_header: String
var content_type_header: String
var request_headers: Array
var bird: BirdInfo
var logger_key = {
	"type": Logger.LogType.DATABASE,
	"obj": "BirdAssetImporter"
}

func _init(bird_name: String)->void:
	bird = BirdInfo.new()
	bird.species = BirdSpecies.new()

func _ready() -> void:
	_create_request()

func import()->void:
	fetch_bird_species()

func fetch_bird_species()->void:
	var url = Database.get_fetch_species_endpoint()
	var request = JSON.stringify({"birdSpecies":bird.species.name})
	http_request.request(url, request_headers, HTTPClient.METHOD_POST, request)
	Logger.print_debug("A bird species request has been sent", logger_key)

func _create_request()->void:
	http_request = HTTPRequest.new()
	auth_header = "Authorization: Bearer " + Database.get_anon_token()
	content_type_header = "Content-Type: application/json"
	request_headers = [auth_header, content_type_header]
	http_request.request_completed.connect(_on_fetch_bird_species_request_complete)
	add_child(http_request)

func _build_species(response_body: Dictionary)->void:
	var simulation_info = response_body.get("birdSimulationInfo") as Dictionary
	bird.species.name = (response_body.get("birdName") as String).capitalize()
	bird.species.max_stamina = randf_range(MIN_STAMINA, MAX_STAMINA)
	bird.species.stamina = randf_range(MIN_STAMINA, bird.species.max_stamina)
	bird.species.ground_cost = 5
	bird.species.can_swim = simulation_info.get("canSwim")
	bird.species.can_fly = simulation_info.get("canFly")
	bird.species.ground_max_distance = randf_range(MIN_GROUND_DISTANCE, MAX_GROUND_DISTANCE)
	bird.species.take_off_cost = 1
	bird.species.flight_cost = 10
	bird.species.flight_max_distance = randf_range(bird.species.ground_max_distance, MAX_FLIGHT_DISTANCE)
	bird.species.preen = simulation_info.get("preen")
	bird.species.takes_dust_baths = simulation_info.get("takesDustBaths")
	bird.species.does_sunbathing = simulation_info.get("doesSunbathing")
	

func _build_info(response_body: Dictionary)->void:
	bird.description = response_body.get("birdDescription")
	bird.family = (response_body.get("birdFamily") as String).capitalize()
	bird.scientific_name = (response_body.get("birdScientificName") as String).capitalize()

func _build_shape()->void:
	bird.species.size = 1.0 ## Fetch From db

func _build_diet()->void:
	pass

func _build_image()->void:
	pass

func _on_fetch_bird_species_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)->void:
	var response_body: Dictionary = JSON.parse_string(body.get_string_from_ascii()).get("data")
	## Take account of genders


func get_bird()->BirdInfo:
	return bird