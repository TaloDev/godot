extends GdUnitTestSuite

var _saved_current_alias: TaloPlayerAlias

func before_test() -> void:
	_saved_current_alias = Talo.current_alias
	Talo.current_alias = null

	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)
	DirAccess.remove_absolute(TaloContinuityManager._CONTINUITY_PATH)

	var config := ConfigFile.new()
	if config.has_section("session"):
		config.erase_section("session")
		config.save(TaloSessionManager._SESSION_CONFIG_PATH)

func after_test() -> void:
	Talo.current_alias = _saved_current_alias

	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)
	DirAccess.remove_absolute(TaloContinuityManager._CONTINUITY_PATH)

	var config := ConfigFile.new()
	if config.has_section("session"):
		config.erase_section("session")
		config.save(TaloSessionManager._SESSION_CONFIG_PATH)

func _write_refresh_token(token: String) -> void:
	var config := ConfigFile.new()
	config.set_value("session", "refreshToken", token)
	config.save(TaloSessionManager._SESSION_CONFIG_PATH)

func test_clear_session_without_identity_still_clears_stored_refresh_token() -> void:
	_write_refresh_token("stale-token")

	var manager := TaloSessionManager.new()
	var result := manager.clear_session()

	assert_int(result).is_equal(ERR_UNAUTHORIZED)
	assert_str(manager.get_refresh_token()).is_empty()

func test_clear_session_with_identity_returns_ok() -> void:
	Talo.current_alias = TaloFixtures.make_alias()

	var manager := TaloSessionManager.new()
	var result := manager.clear_session(false)

	assert_int(result).is_equal(OK)
	assert_object(Talo.current_alias).is_null()
