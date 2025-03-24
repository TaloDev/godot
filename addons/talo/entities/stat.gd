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
	max_change = data.maxChange if data.maxChange else INF
	min_value = data.minValue if data.minValue else -INF
	max_value = data.maxValue if data.maxValue else INF
	min_time_between_updates = data.minTimeBetweenUpdates
	created_at = data.createdAt
	updated_at = data.updatedAt
