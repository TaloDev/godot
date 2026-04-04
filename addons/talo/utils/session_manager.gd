class_name TaloSessionManager extends RefCounted

const _SESSION_CONFIG_PATH = "user://talo_session.cfg"

var _verification_alias_id: int
var _session_token: String

func _load_config(path: String) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(path)
	return config

func _save_session(session_token: String, refresh_token: String) -> void:
	_session_token = session_token

	var config := _load_config(_SESSION_CONFIG_PATH)
	config.set_value("session", "refreshToken", refresh_token)
	if Talo.current_alias:
		config.set_value("session", "identifier", Talo.current_alias.identifier)

	config.save(_SESSION_CONFIG_PATH)

func clear_session(reset_socket: bool = true) -> void:
	_session_token = ""
	Talo.current_alias = null

	if reset_socket:
		Talo.socket.reset_connection()

	var config := _load_config(_SESSION_CONFIG_PATH)
	if config.has_section("session"):
		config.erase_section("session")
		config.save(_SESSION_CONFIG_PATH)

func get_session_token() -> String:
	return _session_token

func get_refresh_token() -> String:
	var config := _load_config(_SESSION_CONFIG_PATH)
	return config.get_value("session", "refreshToken", "")

func get_identifier() -> String:
	var config := _load_config(_SESSION_CONFIG_PATH)
	return config.get_value("session", "identifier", "")

func save_verification_alias_id(alias_id: int) -> void:
	_verification_alias_id = alias_id

func get_verification_alias_id() -> int:
	return _verification_alias_id

func handle_session_created(alias: Dictionary, session_token: String, refresh_token: String, socket_token: String) -> void:
	Talo.current_alias = TaloPlayerAlias.new(alias)
	_save_session(session_token, refresh_token)
	Talo.players.identified.emit(Talo.current_player)
	Talo.socket.set_socket_token(socket_token)

func handle_session_refreshed(session_token: String, refresh_token: String) -> void:
	_save_session(session_token, refresh_token)

func check_for_session() -> bool:
	if not get_session_token().is_empty():
		return true

	if get_refresh_token().is_empty():
		return false

	return await Talo.player_auth.refresh() == OK

func _set_new_alias(alias: TaloPlayerAlias) -> void:
	Talo.current_alias = alias
	alias.write_offline_alias()

func handle_identifier_changed(alias: TaloPlayerAlias) -> void:
	_set_new_alias(alias)

	var config := _load_config(_SESSION_CONFIG_PATH)
	config.set_value("session", "identifier", alias.identifier)
	config.save(_SESSION_CONFIG_PATH)

func handle_account_migrated(alias: TaloPlayerAlias) -> void:
	clear_session(false)
	_set_new_alias(alias)
	Talo.players.identified.emit(Talo.current_player)
