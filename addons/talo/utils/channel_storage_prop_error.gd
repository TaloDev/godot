class_name TaloChannelStoragePropError extends RefCounted

var key: String
var error: String

func _init(key: String, error: String) -> void:
	self.key = key
	self.error = error
