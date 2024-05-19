extends Node

class_name ImageIdentification

var image: PackedByteArray
var http_request: HTTPRequest
var auth_header: String
var content_type_header: String
var headers: Array
var url: String
var logger_key = {
	"type": Logger.LogType.CAMERA,
	"obj": self.name
}


func _init(image: PackedByteArray)->void:
	self.image = image
	auth_header = "Authorization: Bearer " + Database.get_refresh_token()
	content_type_header = "Content-Type: application/octet-stream"
	headers = [auth_header, content_type_header]
	url = Database.get_image_endpoint()

func _ready()->void:
	_create_http_request()

func _create_http_request()->void:
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_image_request_complete)
	add_child(http_request)
	
func _notify_user(message:String, bird:String="")->void:
	var user_message:String = ""
	match message:
		"No bird":
			user_message = "Couldn't find any bird in the photo you took. Please take another photo and try again"
			get_tree().call_group("Dialog", "display", user_message)
			get_tree().call_group("LoadingButton", "hide_loading")
		"Blurry bird":
			# Give a random bird as compensation
			await BirdResourceManager.add_bird("", true)
		"bird":
			# This dosen't do anything, this message is printed in a different part of the code
			# This is just left over code from a previous implementation
			user_message = "You found a "+bird+"!"
		_:
			user_message = "There was an error processing the image"
			get_tree().call_group("Dialog", "display", user_message)
			get_tree().call_group("LoadingButton", "hide_loading")

func _on_image_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)->void:
	var result_body = JSON.parse_string(body.get_string_from_ascii())
	if response_code != HTTPClient.RESPONSE_OK:
		Logger.print_debug("Error retrieving bird: (Response Code) "+str(response_code)+" (Body) "+result_body.get("error"), logger_key)
		await _notify_user(result_body.get("error"))
		_cleanup()
		return
	var bird_species = result_body.get("birdSpecies")
	var approximate = result_body.get("approximate")
	_notify_user("bird", bird_species)
	await BirdResourceManager.add_bird(bird_species)
	_cleanup()

func _cleanup()->void:
	http_request.queue_free()
	queue_free()

func send_request()->void:
	http_request.request_raw(url, headers, HTTPClient.METHOD_POST, image)
	Logger.print_debug("An image request has been sent", logger_key)
