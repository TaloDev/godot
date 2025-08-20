class_name TaloPlayerAlias extends RefCounted

const _OFFLINE_DATA_PATH = "user://ta.bin"

var id: int
var service: String
var identifier: String
var player: TaloPlayer
var last_seen_at: String
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	service = data.service
	identifier = data.identifier
	player = TaloPlayer.new(data.player)
	last_seen_at = data.lastSeenAt
	created_at = data.createdAt
	updated_at = data.updatedAt

static func write_offline_alias(data: Dictionary):
	var file := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.WRITE, Talo.crypto_manager.get_key())
	file.store_line(JSON.stringify(data))

static func get_offline_alias() -> TaloPlayerAlias:
	if not FileAccess.file_exists(_OFFLINE_DATA_PATH):
		return null

	var content := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.READ, Talo.crypto_manager.get_key())
	if content == null:
		TaloCryptoManager.handle_undecryptable_file(_OFFLINE_DATA_PATH, "offline alias file")
		return null

	var json := JSON.new()
	json.parse(content.get_as_text())

	return TaloPlayerAlias.new(json.data)

static func offline_alias_matches_request(offline_alias: TaloPlayerAlias, service: String, identifier: String) -> bool:
	var match = offline_alias.service == service and offline_alias.identifier == identifier
	if not match:
		var dir := DirAccess.open("user://")
		dir.remove(_OFFLINE_DATA_PATH)

	return match
