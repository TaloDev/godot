class_name TaloProp extends Node

var key: String
var value: Variant

func _init(key: String, value: Variant):
	self.key = key
	self.value = str(value) if value != null else value

func to_dictionary() -> Dictionary:
	return { key = key, value = value }
