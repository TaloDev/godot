class_name TaloSessionManager extends Node

var _session_config_path = "user://talo_session.cfg"
var _verification_alias_id = ""

func _load_config(path: String) -> ConfigFile:
	var config = ConfigFile.new()
	config.load(path)
	return config

func _save_session(session_token: String) -> void:
	var config = ConfigFile.new()
	config.set_value("session", "token", session_token)
	config.set_value("session", "identifier", Talo.current_alias.identifier)
	config.save(_session_config_path)

func clear_session() -> void:
	var config = _load_config(_session_config_path)

	if config.has_section("session"):
		config.erase_section("session")
		config.save(_session_config_path)

func get_token() -> String:
	var config = _load_config(_session_config_path)
	return config.get_value("session", "token", "")

func get_identifier() -> String:
	var config = _load_config(_session_config_path)
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
