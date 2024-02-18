extends Node

class_name FetchBirdRequest

var http_request: HTTPRequest
var auth_header: String
var content_type_header: String
var request_headers: Array
var response_body: Dictionary
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "FetchBirdRequest"
}

signal request_processed

func _ready() -> void:
	_create_request()

func fetch_bird_species(bird_name: String, url: String)->Dictionary:
	var request = JSON.stringify({"birdSpecies":bird_name})
	http_request.request(url, request_headers, HTTPClient.METHOD_POST, request)
	Logger.print_debug("A bird species request has been sent", logger_key)
	await request_processed
	http_request.queue_free()
	return response_body

func _create_request()->void:
	http_request = HTTPRequest.new()
	auth_header = "Authorization: Bearer " + Database.get_anon_token()
	content_type_header = "Content-Type: application/json"
	request_headers = [auth_header, content_type_header]
	http_request.request_completed.connect(_on_fetch_bird_species_request_complete)
	add_child(http_request)

func _on_fetch_bird_species_request_complete(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray)->void:
	response_body = JSON.parse_string(body.get_string_from_ascii()) as Dictionary
	if response_code != HTTPClient.RESPONSE_OK:
		Logger.print_debug("Error retrieving bird: (Response Code) "+str(response_code)+" (Body) "+response_body.get("error"), logger_key)
		response_body = {}
		get_tree().call_group("Dialog", "display", "There was an error with the database")
	response_body.make_read_only()
	request_processed.emit()
