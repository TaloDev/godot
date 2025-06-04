class_name TaloChannelStorageProp extends RefCounted

var key: String
var value: String
var created_by_alias: TaloPlayerAlias
var last_updated_by_alias: TaloPlayerAlias
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	key = data.key
	value = data.value
	created_by_alias = TaloPlayerAlias.new(data.createdBy)
	last_updated_by_alias = TaloPlayerAlias.new(data.lastUpdatedBy)
	created_at = data.createdAt
	updated_at = data.updatedAt
