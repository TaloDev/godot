class_name TaloFeedbackCategory extends RefCounted

var id: int
var internal_name: String
var name: String
var description: String
var anonymised: bool
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	internal_name = data.internalName
	name = data.name
	description = data.description
	anonymised = data.anonymised
	created_at = data.createdAt
	updated_at = data.updatedAt
