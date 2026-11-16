class_name TaloClaimKeyManager extends RefCounted
## Claim keys, encrypted in `user://tck.bin`, and the key of the identified player in memory.
##
## `players` maps a player ID to their key. `identities` maps a service+identifier to a key.

const HEADER := "X-Talo-Claim-Key"

const _CLAIM_KEY_PATH = "user://tck.bin"
const _PLAYERS := "players"
const _IDENTITIES := "identities"

var _current_player_id := ""
var _current_key := ""


static func build_headers(claim_key: String) -> Array[String]:
	if claim_key.is_empty():
		return []

	return ["%s: %s" % [HEADER, claim_key]]


static func has_header(headers: Array[String]) -> bool:
	for header in headers:
		if header.begins_with(HEADER):
			return true

	return false


## The player's key, read from the store once per player and then reused.
func get_current_key(player: TaloPlayer) -> String:
	if player == null:
		return ""

	if _current_player_id != player.id:
		_current_player_id = player.id
		_current_key = get_player_key(player.id)

	return _current_key


func clear_current_key() -> void:
	_current_player_id = ""
	_current_key = ""


func get_player_key(player_id: String) -> String:
	var players: Dictionary = _read()[_PLAYERS]
	return players.get(player_id, "")


## The key for an identify request. Defaults to the cached alias's player,
## otherwise the one stored for this service+identifier combo.
func get_identify_key(service: String, identifier: String) -> String:
	var sections := _read()
	var players: Dictionary = sections[_PLAYERS]

	var offline_alias := TaloPlayerAlias.get_offline_alias()
	if offline_alias != null and offline_alias.matches_identify_request(service, identifier):
		var player_key: String = players.get(offline_alias.player.id, "")
		if not player_key.is_empty():
			return player_key

	var identities: Dictionary = sections[_IDENTITIES]
	return identities.get(_identity(service, identifier), "")


## Save a player's claim key. An empty service or identifier is a no-op.
func save_key(
	player_id: String,
	claim_key: String,
	service: String = "",
	identifier: String = "",
) -> void:
	if player_id.is_empty() or claim_key.is_empty():
		return

	var sections := _read()
	var players: Dictionary = sections[_PLAYERS]
	players[player_id] = claim_key

	if not service.is_empty() and not identifier.is_empty():
		var identities: Dictionary = sections[_IDENTITIES]
		identities[_identity(service, identifier)] = claim_key

	_write(sections)
	clear_current_key()


func forget_player(player_id: String) -> void:
	var sections := _read()
	var players: Dictionary = sections[_PLAYERS]

	if players.erase(player_id):
		_write(sections)

	clear_current_key()


func _identity(service: String, identifier: String) -> String:
	return "%s:%s" % [service.strip_edges().to_lower(), identifier.strip_edges()]


func _read() -> Dictionary:
	var sections := { _PLAYERS: { }, _IDENTITIES: { } }
	if not FileAccess.file_exists(_CLAIM_KEY_PATH):
		return sections

	var file := FileAccess.open_encrypted_with_pass(
		_CLAIM_KEY_PATH,
		FileAccess.READ,
		Talo.crypto_manager.get_key(),
	)
	if file == null:
		TaloCryptoManager.handle_undecryptable_file(_CLAIM_KEY_PATH, "claim key file")
		return sections

	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()

	if not json.data is Dictionary:
		return sections

	var stored: Dictionary = json.data
	for section in sections:
		var section_data: Variant = stored.get(section)
		if section_data is Dictionary:
			sections[section] = section_data

	return sections


func _write(sections: Dictionary) -> void:
	var file := FileAccess.open_encrypted_with_pass(
		_CLAIM_KEY_PATH,
		FileAccess.WRITE,
		Talo.crypto_manager.get_key(),
	)
	file.store_line(JSON.stringify(sections))
	file.close()
