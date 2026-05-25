class_name TaloChannelStoragePropError extends RefCounted

var key: String
var error: String
var message: String

func _init(key: String, error: String, message: String) -> void:
	self.key = key
	self.error = error
	self.message = message
