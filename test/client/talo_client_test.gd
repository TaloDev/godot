extends GdUnitTestSuite

const LARGE_BODY_FILLER_SIZE := 2000


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


func test_compression_can_be_disabled() -> void:
	var request_body := JSON.stringify({ data = "x".repeat(LARGE_BODY_FILLER_SIZE) })
	var compress_requests := Talo.settings.compress_requests
	Talo.settings.compress_requests = false
	var encoded := _encode(request_body)
	Talo.settings.compress_requests = compress_requests

	assert_bool(encoded.gzipped).is_false()
	assert_that(encoded.bytes).is_equal(request_body.to_utf8_buffer())
