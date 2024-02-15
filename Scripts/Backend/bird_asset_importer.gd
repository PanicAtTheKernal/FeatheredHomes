extends Node

class_name BirdAssetImporter

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
	bird.species.name = response_body.get("birdName")

func _build_info(response_body: Dictionary)->void:
	bird.description = response_body.get("birdDescription")
	bird.family = response_body.get("birdFamily")

func _on_fetch_bird_species_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)->void:
	var response_body: Dictionary = JSON.parse_string(body.get_string_from_ascii()).get("data")


func get_bird()->BirdInfo:
	return bird