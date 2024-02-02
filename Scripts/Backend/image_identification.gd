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
	auth_header = "Authorization: Bearer " + Database.get_anon_token()
	content_type_header = "Content-Type: application/octet-stream"
	headers = [auth_header, content_type_header]
	url = Database.get_image_endpoint()

func _ready():
	_create_http_request()

func _create_http_request()->void:
	http_request = HTTPRequest.new()
	http_request.request_completed.connect(_on_image_request_complete)
	add_child(http_request)
	
func _notify_user(message:String)->void:
	get_tree().call_group("Dialog", "display", message)
	get_tree().call_group("LoadingButton", "hide_loading")

func _on_image_request_complete(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray)->void:
	if response_code != HTTPClient.RESPONSE_OK:
		Logger.print_debug("Error retrieving bird: (Status) "+str(result)+" (Response Code) "+str(response_code)+" (Body) "+body.get_string_from_ascii(), logger_key)
		_notify_user("Unable to process image")
		_cleanup()
		return
	var result_body = JSON.parse_string(body.get_string_from_ascii())
	var bird_species = result_body.get("birdSpecies")
	_notify_user(("You found a "+bird_species))
	BirdResourceManager.add_bird(bird_species)
	await BirdResourceManager.new_bird
	# Add the bird importer
	# TODO fix the response, as in the thing should throw an error if there are not bird labels or there is not bird 
	_cleanup()

func _cleanup()->void:
	http_request.queue_free()
	queue_free()

func send_request()->void:
	http_request.request_raw(url, headers, HTTPClient.METHOD_POST, image)
	Logger.print_debug("An image request has been sent", logger_key)
