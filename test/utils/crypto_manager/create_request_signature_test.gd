extends GdUnitTestSuite

const BODY := "{\"foo\":\"bar\"}"
const KEY_VERSION := "1"
const KEY_VALUE := "test-key"


func before() -> void:
	Talo.settings.verification_key_version = KEY_VERSION
	Talo.settings.verification_key_value = KEY_VALUE
	Talo.settings.verification_enabled = true


func after() -> void:
	Talo.settings.verification_key_version = ""
	Talo.settings.verification_key_value = ""
	Talo.settings.verification_enabled = false


func _read_header(token: String) -> Dictionary:
	var header_b64: String = token.split("|")[1].split(".")[0]

	var json := JSON.new()
	json.parse(Marshalls.base64_to_utf8(header_b64))

	return json.data


func test_token_header_decodes_and_contains_valid_payload() -> void:
	var header := _read_header(TaloCryptoManager.create_request_signature(BODY))

	var payload: String = header.payload
	assert_str(payload).is_equal(BODY.sha256_text())

	var timestamp: int = header.timestamp
	assert_int(timestamp).is_greater(0)


func test_token_signature_verifies_with_key_value() -> void:
	var token := TaloCryptoManager.create_request_signature(BODY)
	var header_b64: String = token.split("|")[1].split(".")[0]
	var signature_b64: String = token.split("|")[1].split(".")[1]

	var hmac := HMACContext.new()
	hmac.start(HashingContext.HASH_SHA256, KEY_VALUE.to_utf8_buffer())
	hmac.update(header_b64.to_utf8_buffer())
	var expected_sig_b64: String = Marshalls.raw_to_base64(hmac.finish())

	assert_str(signature_b64).is_equal(expected_sig_b64)


func test_token_uses_configured_key_version() -> void:
	assert_str(TaloCryptoManager.create_request_signature(BODY)).starts_with(KEY_VERSION + "|")


func test_signing_same_body_twice_yields_different_nonces() -> void:
	var first := _read_header(TaloCryptoManager.create_request_signature(BODY))
	var second := _read_header(TaloCryptoManager.create_request_signature(BODY))

	assert_str(first.rid).is_not_equal(second.rid)


func test_nonce_has_expected_length() -> void:
	var nonce: String = _read_header(TaloCryptoManager.create_request_signature(BODY)).rid

	assert_int(nonce.length()).is_equal(16)
