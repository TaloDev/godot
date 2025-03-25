class_name TaloPlayerStat extends RefCounted

var id: int
var stat: TaloStat
var value: float
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	stat = TaloStat.new(data.stat)
	value = data.value
	created_at = data.createdAt
	updated_at = data.updatedAt
