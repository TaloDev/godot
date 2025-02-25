class_name TaloGameSave extends RefCounted

var id: int
var name: String
var content: Dictionary
var updated_at: String

func _init(data: Dictionary) -> void:
	id = data.id if data.has("id") else 0
	name = data.name
	content = data.content
	updated_at = data.updatedAt

func to_dictionary() -> Dictionary:
	return {
		id = id,
		name = name,
		content = content,
		updatedAt = updated_at
	}
