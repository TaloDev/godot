class_name TaloCryptoManager extends RefCounted

const _KEY_FILE_PATH = "user://ti.bin"

static func handle_undecryptable_file(path: String, what: String) -> void:
	push_error("Failed to decrypt %s" % what)
	var split_path := path.split(".")
	var timestamp := TaloTimeUtils.get_timestamp_msec()
	DirAccess.rename_absolute(path, "%s-invalid-%s.%s" % [split_path[0], timestamp, split_path[1]])

func _get_pass() -> String:
	if OS.has_feature("web"):
		return Talo.settings.access_key

	return OS.get_unique_id()

func _init() -> void:
	if not FileAccess.file_exists(_KEY_FILE_PATH):
		if _get_pass().is_empty():
			push_error("Unable to create key file: cannot generate a suitable password")
			return

		var crypto := Crypto.new()
		var key := crypto.generate_random_bytes(32).hex_encode()

		var file := FileAccess.open_encrypted_with_pass(_KEY_FILE_PATH, FileAccess.WRITE, _get_pass())
		file.store_line(key)
		file.close()

func get_key() -> String:
	if not FileAccess.file_exists(_KEY_FILE_PATH):
		_init()

	var file := FileAccess.open_encrypted_with_pass(_KEY_FILE_PATH, FileAccess.READ, _get_pass())
	if file == null:
		handle_undecryptable_file(_KEY_FILE_PATH, "crypto init file")
		return ""

	var key := file.get_as_text()
	file.close()
	return key
