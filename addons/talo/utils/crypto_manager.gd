class_name TaloCryptoManager extends Node

var _key_file_path = "user://talo_init.bin"

func _get_pass() -> String:
  return Talo.settings.get_value("", "access_key")

func _init() -> void:
  if not FileAccess.file_exists(_key_file_path):
    if _get_pass().is_empty():
      push_error("Talo access_key in settings.cfg is empty")
      return

    var crypto = Crypto.new()
    var key = crypto.generate_random_bytes(32).hex_encode()

    var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.WRITE, _get_pass())
    file.store_line(key)
    file.close()

func get_key() -> String:
  if not FileAccess.file_exists(_key_file_path):
    push_error("Talo key file has not been created: access_key might be empty")
    return ""

  var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.READ, _get_pass())
  var key = file.get_as_text()
  file.close()
  return key
