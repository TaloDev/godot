class_name TaloPlayerStatSnapshot extends RefCounted

var player_alias: TaloPlayerAlias
var change: float
var value: float
var global_value: float
var created_at: String

func _init(data: Dictionary):
	player_alias = TaloPlayerAlias.new(data.playerAlias)
	change = data.change
	value = data.value
	global_value = data.get("globalValue", 0.0)
	created_at = data.createdAt
