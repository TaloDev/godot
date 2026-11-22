extends GdUnitTestSuite

var _saved_current_alias: TaloPlayerAlias


func before_test() -> void:
	_saved_current_alias = Talo.current_alias
	Talo.current_alias = null
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloContinuityManager._CONTINUITY_PATH)

	var config := ConfigFile.new()
	if config.has_section("session"):
		config.erase_section("session")
		config.save(TaloSessionManager._SESSION_CONFIG_PATH) # gdlint-ignore-line private-access


func after_test() -> void:
	Talo.current_alias = _saved_current_alias
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloContinuityManager._CONTINUITY_PATH)

	var config := ConfigFile.new()
	if config.has_section("session"):
		config.erase_section("session")
		config.save(TaloSessionManager._SESSION_CONFIG_PATH) # gdlint-ignore-line private-access


func _write_refresh_token(token: String) -> void:
	var config := ConfigFile.new()
	config.set_value("session", "refreshToken", token)
	config.save(TaloSessionManager._SESSION_CONFIG_PATH) # gdlint-ignore-line private-access


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


func test_clear_session_clears_the_claim_key() -> void:
	Talo.current_alias = TaloFixtures.make_alias()
	Talo.claim_key_manager.clear_current_key()

	var manager := TaloSessionManager.new()
	manager.clear_session(false)

	# the key must not come back when the same player is identified again
	Talo.current_alias = TaloFixtures.make_alias()
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_empty()


func test_handle_session_created_does_not_carry_the_key_to_another_player() -> void:
	Talo.current_alias = TaloFixtures.make_alias()
	Talo.claim_key_manager.clear_current_key()

	var manager := TaloSessionManager.new()
	manager.handle_session_created(
		TaloFixtures.player_alias_factory({ "player": { "id": "player-2" } }),
		"session",
		"refresh",
		"",
	)

	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_empty()
