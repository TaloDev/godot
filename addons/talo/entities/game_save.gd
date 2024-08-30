class_name TaloGameSave extends Node

var id: int
var display_name: String
var content: Dictionary
var updated_at: String

func _init(data: Dictionary) -> void:
	id = data.id if data.has("id") else 0
	display_name = data.name
	content = data.content
	updated_at = data.updatedAt

func to_dictionary() -> Dictionary:
	return {
		id = id,
		name = display_name,
		content = content,
		updatedAt = updated_at
	}
