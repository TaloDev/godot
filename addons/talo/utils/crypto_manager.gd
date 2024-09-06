class_name TaloCryptoManager extends Node

var _key_file_path = "user://talo_init.bin"

func _get_pass() -> String:
  return Talo.settings.get_value("", "access_key")

func _init() -> void:
  if not FileAccess.file_exists(_key_file_path) and not _get_pass().is_empty():
    var crypto = Crypto.new()
    var key = crypto.generate_random_bytes(32).hex_encode()

    var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.WRITE, _get_pass())
    file.store_line(key)
    file.close()

func get_key() -> String:
  var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.READ, _get_pass())
  var key = file.get_as_text()
  file.close()
  return key
