class_name TaloProp extends Node

var key: String
var value: String

func _init(key: String, value: String):
	self.key = key
	self.value = value

func to_dictionary() -> Dictionary:
	return { key = key, value = value }
