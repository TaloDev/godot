extends GdUnitTestSuite

func test_from_response_with_error_code_and_message_uses_both() -> void:
	var err := TaloPlayerAuthError.from_response({
		errorCode = "INVALID_CREDENTIALS",
		message = "Current password is incorrect"
	})

	assert_int(err.error).is_equal(TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS)
	assert_str(err.message).is_equal("Current password is incorrect")

func test_from_response_with_error_code_only_uses_unknown_error_message() -> void:
	var err := TaloPlayerAuthError.from_response({
		errorCode = "INVALID_CREDENTIALS"
	})

	assert_int(err.error).is_equal(TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS)
	assert_str(err.message).is_equal("Unknown error")

func test_from_response_with_message_only_falls_back_to_api_error_code() -> void:
	var err := TaloPlayerAuthError.from_response({
		message = "Something went wrong"
	})

	assert_int(err.error).is_equal(TaloPlayerAuthError.ErrorCode.API_ERROR)
	assert_str(err.message).is_equal("Something went wrong")

func test_from_response_with_null_body_uses_api_error_defaults() -> void:
	var err := TaloPlayerAuthError.from_response(null)

	assert_int(err.error).is_equal(TaloPlayerAuthError.ErrorCode.API_ERROR)
	assert_str(err.message).is_equal("API error - see the Errors Output for more details")

func test_from_response_with_unknown_error_code_falls_back_to_api_error() -> void:
	var err := TaloPlayerAuthError.from_response({
		errorCode = "NOPE",
		message = "some message"
	})

	assert_int(err.error).is_equal(TaloPlayerAuthError.ErrorCode.API_ERROR)
	assert_str(err.message).is_equal("some message")
