extends Node

var logger_key = {
	"type": Logger.LogType.UI,
	"obj": "GlobalDialog"
}

func create(dialog: Dialog) -> void:
	var ui = get_tree().root.find_child("UI", true, false)
	if ui != null:
		ui.add_child(dialog)
	else:
		Logger.print_debug("Unable to find UI in current scene", logger_key)
