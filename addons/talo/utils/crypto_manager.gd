class_name TaloCryptoManager extends Node

var _key_file_path = "user://ti.bin"

static func handle_undecryptable_file(path: String, what: String) -> void:
	push_error("Failed to decrypt %s" % what)
	var split_path = path.split(".")
	var timestamp = TimeUtils.get_timestamp_msec()
	DirAccess.rename_absolute(path, "%s-invalid-%s.%s" % [split_path[0], timestamp, split_path[1]])

func _get_pass() -> String:
	if OS.has_feature("web"):
		return Talo.settings.get_value("", "access_key")

	return OS.get_unique_id()

func _init() -> void:
	if not FileAccess.file_exists(_key_file_path):
		if _get_pass().is_empty():
			push_error("Unable to create key file: cannot generate a suitable password")
			return

		var crypto = Crypto.new()
		var key = crypto.generate_random_bytes(32).hex_encode()

		var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.WRITE, _get_pass())
		file.store_line(key)
		file.close()

func get_key() -> String:
	if not FileAccess.file_exists(_key_file_path):
		_init()

	var file = FileAccess.open_encrypted_with_pass(_key_file_path, FileAccess.READ, _get_pass())
	if file == null:
		handle_undecryptable_file(_key_file_path, "crypto init file")
		return ""

	var key = file.get_as_text()
	file.close()
	return key
