class_name TaloSessionManager extends Node

var _config_file_path = "user://talo_session.cfg"

func _init() -> void:
  Talo.players.identified.connect(_check_session)

func _load_config() -> ConfigFile:
  var config = ConfigFile.new()
  config.load(_config_file_path)
  return config

func save_session(session_token: String) -> void:
  var config = ConfigFile.new()
  config.set_value("session", "token", session_token)
  config.set_value("session", "identifier", Talo.current_alias.identifier)
  config.save(_config_file_path)

func _check_session(_player: TaloPlayer) -> void:
  if Talo.current_alias.service != "talo":
    clear_session()

func clear_session() -> void:
  var config = _load_config()
  config.erase_section("session")
  config.save(_config_file_path)

func load_session() -> String:
  var config = _load_config()
  return config.get_value("session", "token", "")

func get_identifier() -> String:
  var config = _load_config()
  return config.get_value("session", "identifier", "")

func save_verification_alias_id(alias_id: int) -> void:
  var config = _load_config()
  config.set_value("verification", "alias_id", str(alias_id))
  config.save(_config_file_path)

func get_verification_alias_id() -> String:
  var config = _load_config()
  return config.get_value("verification", "alias_id", "")
