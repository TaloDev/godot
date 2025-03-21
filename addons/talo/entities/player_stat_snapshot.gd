class_name TaloPlayerStatSnapshot extends RefCounted

var change: float
var value: float
var global_value: float
var created_at: String

func _init(data: Dictionary):
	change = data.change
	value = data.value
	global_value = data.globalValue
	created_at = data.createdAt
