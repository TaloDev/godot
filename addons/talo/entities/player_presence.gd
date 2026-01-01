class_name TaloPlayerPresence extends RefCounted

var online: bool
var custom_status: String
var player_alias: TaloPlayerAlias
var updated_at: String

static func get_default_data() -> Dictionary:
	return {
		online = false,
		customStatus = "",
		playerAlias = null,
		updatedAt = TaloTimeUtils.get_current_datetime_string()
	}

func _init(data: Dictionary):
	online = data.online
	custom_status = data.customStatus
	if data.get("playerAlias") != null:
		player_alias = TaloPlayerAlias.new(data.playerAlias)
	updated_at = data.updatedAt
