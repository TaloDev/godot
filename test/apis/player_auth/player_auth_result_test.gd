extends GdUnitTestSuite

func test_player_auth_result_with_no_error_is_success() -> void:
	var result := PlayerAuthAPI.PlayerAuthResult.new()

	assert_bool(result.success).is_true()
	assert_object(result.error).is_null()

func test_player_auth_result_with_error_is_failure() -> void:
	var err := TaloPlayerAuthError.new(TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS, "nope")
	var result := PlayerAuthAPI.PlayerAuthResult.new(err)

	assert_bool(result.success).is_false()
	assert_object(result.error).is_same(err)

func test_player_auth_login_result_with_no_error_is_success() -> void:
	var result := PlayerAuthAPI.PlayerAuthLoginResult.new()

	assert_bool(result.success).is_true()
	assert_bool(result.verification_required).is_false()
	assert_object(result.error).is_null()

func test_player_auth_login_result_with_verification_required_is_success() -> void:
	var result := PlayerAuthAPI.PlayerAuthLoginResult.new(null, true)

	assert_bool(result.success).is_true()
	assert_bool(result.verification_required).is_true()
	assert_object(result.error).is_null()

func test_player_auth_login_result_with_error_defaults_to_no_verification() -> void:
	var err := TaloPlayerAuthError.new(TaloPlayerAuthError.ErrorCode.INVALID_CREDENTIALS, "nope")
	var result := PlayerAuthAPI.PlayerAuthLoginResult.new(err)

	assert_bool(result.success).is_false()
	assert_bool(result.verification_required).is_false()
	assert_object(result.error).is_same(err)
