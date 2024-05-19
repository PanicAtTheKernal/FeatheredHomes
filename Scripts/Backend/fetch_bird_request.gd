extends Node

class_name FetchBirdRequest

var http_request: HTTPRequest
var auth_header: String
var content_type_header: String
var request_headers: Array
var response_body: Dictionary
var response_code: int
var bird_name_request: String
var logger_key = {
	"type": Logger.LogType.RESOURCE,
	"obj": "FetchBirdRequest"
}

signal request_processed

func _ready() -> void:
	_create_request()

func fetch_bird_species(bird_name: String, url: String)->Dictionary:
	bird_name_request = bird_name
	var request = JSON.stringify({"birdSpecies":bird_name})
	http_request.request(url, request_headers, HTTPClient.METHOD_POST, request)
	Logger.print_debug("A bird species request has been sent", logger_key)
	await request_processed
	http_request.queue_free()
	return response_body

func _create_request()->void:
	http_request = HTTPRequest.new()
	auth_header = "Authorization: Bearer " + Database.get_refresh_token()
	content_type_header = "Content-Type: application/json"
	request_headers = [auth_header, content_type_header]
	http_request.request_completed.connect(_on_fetch_bird_species_request_complete)
	add_child(http_request)

func _on_fetch_bird_species_request_complete(_result: int, response_code_a: int, _headers: PackedStringArray, body: PackedByteArray)->void:
	if response_code_a == HTTPClient.RESPONSE_BAD_GATEWAY or response_code_a == HTTPClient.RESPONSE_UNAUTHORIZED:
		var error_dialog = Dialog.new().message("There was an error with the database").regular_notification()
		GlobalDialog.create(error_dialog)
		request_processed.emit()
		return
	response_body = JSON.parse_string(body.get_string_from_ascii()) as Dictionary
	if response_code_a != HTTPClient.RESPONSE_OK:
		Logger.print_debug("Error retrieving bird: (Response Code) "+str(response_code_a)+" (Body) "+response_body.get("error"), logger_key)
		if response_body["error"] == "No template found":
			var error_dialog = Dialog.new().message(str("You found a ",bird_name_request," but it can't be generated at this time :( Please check the search button to see all bird families supported")).regular_notification()
			GlobalDialog.create(error_dialog)
		else:		
			var error_dialog = Dialog.new().message("There was an error with the database")
			GlobalDialog.create(error_dialog)
		response_body = {}
	response_body.make_read_only()
	request_processed.emit()
