class_name TaloStat extends RefCounted

var id: int
var internal_name: String
var name: String
var global: bool
var global_value: float
var default_value: float
var max_change: float
var min_value: float
var max_value: float
var min_time_between_updates: int
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	internal_name = data.internalName
	name = data.name
	global = data.global
	global_value = data.globalValue
	default_value = data.defaultValue
	max_change = data.maxChange
	min_value = data.minValue
	max_value = data.maxValue
	min_time_between_updates = data.minTimeBetweenUpdates
	created_at = data.createdAt
	updated_at = data.updatedAt
