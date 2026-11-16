extends GdUnitTestSuite

const LARGE_BODY_FILLER_SIZE := 2000

var _saved_current_alias: TaloPlayerAlias


func before_test() -> void:
	_saved_current_alias = Talo.current_alias
	Talo.current_alias = null

	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)


func after_test() -> void:
	Talo.current_alias = _saved_current_alias

	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)


func _encode(request_body: String) -> Dictionary[String, Variant]:
	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	# gdlint-ignore-next-line private-access
	return client._encode_request_body(request_body)


func test_small_body_is_not_compressed() -> void:
	var request_body := JSON.stringify({ message = "hello" })
	var encoded := _encode(request_body)
	var encoded_bytes: PackedByteArray = encoded.bytes

	assert_bool(encoded.gzipped).is_false()
	assert_that(encoded_bytes).is_equal(request_body.to_utf8_buffer())


func test_large_body_is_gzipped() -> void:
	var request_body := JSON.stringify({ data = "x".repeat(LARGE_BODY_FILLER_SIZE) })
	var original_bytes := request_body.to_utf8_buffer()
	var encoded := _encode(request_body)
	var encoded_bytes: PackedByteArray = encoded.bytes

	assert_bool(encoded.gzipped).is_true()
	assert_int(encoded_bytes.size()).is_less(original_bytes.size())
	assert_str(
		encoded_bytes
		.decompress(original_bytes.size(), FileAccess.COMPRESSION_GZIP)
		.get_string_from_utf8()
	).is_equal(request_body)


func test_empty_body_is_not_compressed() -> void:
	var encoded := _encode("")
	var encoded_bytes: PackedByteArray = encoded.bytes

	assert_bool(encoded.gzipped).is_false()
	assert_int(encoded_bytes.size()).is_equal(0)


func test_read_body_falls_back_to_empty_dictionary() -> void:
	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	# gdlint-ignore-next-line private-access
	assert_dict(client._read_body(null)).is_empty()
	# gdlint-ignore-next-line private-access
	assert_dict(client._read_body("<html>502 Bad Gateway</html>")).is_empty()
	# gdlint-ignore-next-line private-access
	assert_dict(client._read_body({ message = "nope" })).contains_key_value("message", "nope")


func test_compression_can_be_disabled() -> void:
	var request_body := JSON.stringify({ data = "x".repeat(LARGE_BODY_FILLER_SIZE) })
	var compress_requests := Talo.settings.compress_requests
	Talo.settings.compress_requests = false
	var encoded := _encode(request_body)
	Talo.settings.compress_requests = compress_requests

	assert_bool(encoded.gzipped).is_false()
	assert_that(encoded.bytes).is_equal(request_body.to_utf8_buffer())


func test_claim_key_header_is_sent_when_the_player_has_one() -> void:
	var alias := TaloFixtures.make_alias()
	Talo.claim_key_manager.save_key(alias.player.id, "the-key")
	Talo.current_alias = alias

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var headers: Array[String] = client._build_headers() # gdlint-ignore-line private-access

	assert_array(headers).contains(["X-Talo-Claim-Key: the-key"])


func test_claim_key_header_is_omitted_when_the_player_has_none() -> void:
	Talo.current_alias = TaloFixtures.make_alias()

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var headers: Array[String] = client._build_headers() # gdlint-ignore-line private-access

	assert_array(headers).contains(["X-Talo-Player: player-1"])
	assert_bool(_has_claim_key_header(headers)).is_false()


func test_a_caller_claim_key_replaces_the_current_one() -> void:
	var alias := TaloFixtures.make_alias()
	Talo.claim_key_manager.save_key(alias.player.id, "current-key")
	Talo.current_alias = alias

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var extra_headers := TaloClaimKeyManager.build_headers("caller-key")
	# gdlint-ignore-next-line private-access
	var headers: Array[String] = client._build_headers(extra_headers)

	var claim_key_headers := headers.filter(
		func(header: String) -> bool:
			return header.begins_with(TaloClaimKeyManager.HEADER),
	)

	# a second header line would arrive joined with ", " and be rejected by the backend
	assert_array(headers).contains(["X-Talo-Claim-Key: caller-key"])
	assert_int(claim_key_headers.size()).is_equal(1)


func test_claim_key_header_is_omitted_when_identity_is_null() -> void:
	var alias := TaloFixtures.make_alias()
	Talo.claim_key_manager.save_key(alias.player.id, "the-key")
	Talo.current_alias = alias

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var headers: Array[String] = client._build_headers([], null) # gdlint-ignore-line private-access

	assert_bool(_has_claim_key_header(headers)).is_false()
	assert_bool(_has_header(headers, "X-Talo-Player")).is_false()


func test_claim_key_header_is_omitted_for_another_player() -> void:
	Talo.claim_key_manager.save_key("player-2", "other-key")
	Talo.current_alias = TaloFixtures.make_alias()

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var headers: Array[String] = client._build_headers() # gdlint-ignore-line private-access

	assert_bool(_has_claim_key_header(headers)).is_false()


func test_requests_that_write_are_signed_without_an_identified_player() -> void:
	var enabled := Talo.settings.verification_enabled
	var version := Talo.settings.verification_key_version
	var value := Talo.settings.verification_key_value
	Talo.settings.verification_enabled = true
	Talo.settings.verification_key_version = "1"
	Talo.settings.verification_key_value = "secret"

	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var post_headers: Array[String] = []
	var get_headers: Array[String] = []
	# gdlint-ignore-next-line private-access
	client._add_signature(post_headers, HTTPClient.METHOD_POST, "{}")
	# gdlint-ignore-next-line private-access
	client._add_signature(get_headers, HTTPClient.METHOD_GET, "")

	Talo.settings.verification_enabled = enabled
	Talo.settings.verification_key_version = version
	Talo.settings.verification_key_value = value

	assert_bool(_has_header(post_headers, "X-Talo-Signature")).is_true()
	assert_bool(_has_header(get_headers, "X-Talo-Signature")).is_false()


func test_requests_are_not_signed_when_verification_is_off() -> void:
	var client: TaloClient = auto_free(TaloClient.new("/v1"))
	var headers: Array[String] = []
	# gdlint-ignore-next-line private-access
	client._add_signature(headers, HTTPClient.METHOD_POST, "{}")

	assert_array(headers).is_empty()


func _has_header(headers: Array[String], header_name: String) -> bool:
	return headers.any(
		func(header: String) -> bool:
			return header.begins_with("%s:" % header_name),
	)


func _has_claim_key_header(headers: Array[String]) -> bool:
	return _has_header(headers, TaloClaimKeyManager.HEADER)
