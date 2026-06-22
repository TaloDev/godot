class_name TaloPlayerAlias extends RefCounted

const _OFFLINE_DATA_PATH = "user://ta.bin"

var id: int
var service: String
var identifier: String
var display_name: String
var player: TaloPlayer
var last_seen_at: String
var created_at: String
var updated_at: String

var _offline_data: Dictionary

func _init(data: Dictionary):
	id = data.id
	service = data.service
	identifier = data.identifier
	display_name = data.displayName
	player = TaloPlayer.new(data.player)
	last_seen_at = data.lastSeenAt
	created_at = data.createdAt
	updated_at = data.updatedAt
	_offline_data = data

## Cache the offline alias data.
func write_offline_alias():
	if Talo.settings.cache_player_on_identify:
		_offline_data.player = player.get_offline_data()
		var file := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.WRITE, Talo.crypto_manager.get_key())
		file.store_line(JSON.stringify(_offline_data))
		file.close()

## Check if a usable offline alias file exists on disk.
static func has_offline_alias() -> bool:
	return Talo.settings.cache_player_on_identify and FileAccess.file_exists(_OFFLINE_DATA_PATH)

## Get the offline alias data.
static func get_offline_alias() -> TaloPlayerAlias:
	if not has_offline_alias():
		return null

	var file := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.READ, Talo.crypto_manager.get_key())
	if file == null:
		TaloCryptoManager.handle_undecryptable_file(_OFFLINE_DATA_PATH, "offline alias file")
		return null

	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()

	return TaloPlayerAlias.new(json.data)

## Delete the file containing the offline alias data.
static func delete_offline_alias() -> void:
	if FileAccess.file_exists(_OFFLINE_DATA_PATH):
		var dir := DirAccess.open("user://")
		dir.remove(_OFFLINE_DATA_PATH)

## Check if this alias matches the identify request.
func matches_identify_request(service: String, identifier: String) -> bool:
	return self.service == service and self.identifier == identifier
