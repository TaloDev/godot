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

static func get_hashed_time(size := 16) -> String:
	var time_hash := str(TaloTimeUtils.get_timestamp_msec()).sha256_text()
	var split_start := RandomNumberGenerator.new().randi_range(0, time_hash.length() - size)
	return time_hash.substr(split_start, size)

static func create_request_signature(request_body: String) -> String:
	if Talo.settings.verification_key_version.is_empty() or Talo.settings.verification_key_value.is_empty():
		push_error("Verification is enabled but verification_key_version or verification_key_value is missing. Please update your Talo settings.cfg")
		return "" 

	var timestamp := TaloTimeUtils.get_timestamp_msec()
	var payload := JSON.stringify({
		rid = TaloCryptoManager.get_hashed_time(),
		payload = request_body.sha256_text(),
		timestamp = timestamp
	})

	var header_b64 := Marshalls.utf8_to_base64(payload)

	var hmac := HMACContext.new()
	hmac.start(HashingContext.HASH_SHA256, Talo.settings.verification_key_value.to_utf8_buffer())
	hmac.update(header_b64.to_utf8_buffer())
	var signature_b64 := Marshalls.raw_to_base64(hmac.finish())

	return "%s|%s.%s" % [Talo.settings.verification_key_version, header_b64, signature_b64]
