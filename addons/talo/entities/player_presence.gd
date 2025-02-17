class_name TaloPlayerPresence extends Node

var online: bool
var custom_status: String
var player_alias: TaloPlayerAlias
var updated_at: String

func _init(data: Dictionary):
	online = data.online
	custom_status = data.customStatus
	player_alias = null if data.playerAlias == null else TaloPlayerAlias.new(data.playerAlias)
	updated_at = data.updatedAt
