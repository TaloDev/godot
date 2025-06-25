class_name TaloSessionManager extends RefCounted

var _verification_alias_id: int

const _SESSION_CONFIG_PATH = "user://talo_session.cfg"

func _load_config(path: String) -> ConfigFile:
	var config := ConfigFile.new()
	config.load(path)
	return config

func _save_session(session_token: String) -> void:
	var config := ConfigFile.new()
	config.set_value("session", "token", session_token)
	config.set_value("session", "identifier", Talo.current_alias.identifier)
	config.save(_SESSION_CONFIG_PATH)

func clear_session() -> void:
	Talo.current_alias = null
	Talo.socket.reset_connection()

	var config := _load_config(_SESSION_CONFIG_PATH)

	if config.has_section("session"):
		config.erase_section("session")
		config.save(_SESSION_CONFIG_PATH)

func get_token() -> String:
	var config := _load_config(_SESSION_CONFIG_PATH)
	return config.get_value("session", "token", "")

func get_identifier() -> String:
	var config := _load_config(_SESSION_CONFIG_PATH)
	return config.get_value("session", "identifier", "")

func save_verification_alias_id(alias_id: int) -> void:
	_verification_alias_id = alias_id

func get_verification_alias_id() -> int:
	return _verification_alias_id

func handle_session_created(alias: Dictionary, session_token: String, socket_token: String) -> void:
	Talo.current_alias = TaloPlayerAlias.new(alias)
	Talo.players.identified.emit(Talo.current_player)
	_save_session(session_token)
	Talo.socket.set_socket_token(socket_token)

func check_for_session() -> bool:
	return not get_token().is_empty()
