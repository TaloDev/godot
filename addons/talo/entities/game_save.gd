class_name TaloGameSave extends Node

var id: int
var display_name: String
var content: Dictionary
var updated_at: String

func _init(data: Dictionary) -> void:
	id = data.id
	display_name = data.name
	content = data.content
	updated_at = data.updatedAt
