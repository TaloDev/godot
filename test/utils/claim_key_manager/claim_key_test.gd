extends GdUnitTestSuite


func before_test() -> void:
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)


func after_test() -> void:
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)


func test_returns_empty_for_an_unknown_player() -> void:
	assert_str(TaloClaimKeyManager.new().get_player_key("player-1")).is_empty()


func test_returns_empty_for_an_unknown_identify_request() -> void:
	assert_str(TaloClaimKeyManager.new().get_identify_key("username", "bob")).is_empty()


func test_saves_the_key_for_a_player() -> void:
	TaloClaimKeyManager.new().save_key("player-1", "caller-key", "username", "bob")

	# a new instance reads the key back from disk
	assert_str(TaloClaimKeyManager.new().get_player_key("player-1")).is_equal("caller-key")


func test_saves_the_key_for_an_identify_request() -> void:
	TaloClaimKeyManager.new().save_key("player-1", "caller-key", "username", "bob")

	assert_str(TaloClaimKeyManager.new().get_identify_key("username", "bob")).is_equal("caller-key")


func test_prefers_the_key_of_the_cached_player() -> void:
	var cache_setting := Talo.settings.cache_player_on_identify
	Talo.settings.cache_player_on_identify = true

	var offline_alias := TaloFixtures.make_alias(
		{ "player_alias": { "service": "username", "identifier": "bob" } }
	)
	offline_alias.write_offline_alias()

	var manager := TaloClaimKeyManager.new()
	manager.save_key("player-9", "request-key", "username", "bob")
	manager.save_key("player-1", "player-key", "steam", "12345")

	var key := manager.get_identify_key("username", "bob")
	Talo.settings.cache_player_on_identify = cache_setting

	assert_str(key).is_equal("player-key")


func test_keys_are_stored_per_player() -> void:
	var manager := TaloClaimKeyManager.new()
	manager.save_key("player-1", "first-key", "username", "bob")
	manager.save_key("player-2", "second-key", "username", "alice")

	assert_str(manager.get_player_key("player-1")).is_equal("first-key")
	assert_str(manager.get_player_key("player-2")).is_equal("second-key")


func test_saving_without_a_key_is_ignored() -> void:
	var manager := TaloClaimKeyManager.new()
	manager.save_key("player-1", "", "username", "bob")

	assert_str(manager.get_player_key("player-1")).is_empty()


func test_saving_without_an_identity_records_only_the_player() -> void:
	var manager := TaloClaimKeyManager.new()
	manager.save_key("player-1", "caller-key")

	assert_str(manager.get_player_key("player-1")).is_equal("caller-key")
	# gdlint-ignore-next-line private-access
	var players: Dictionary = manager._read()["players"]
	assert_int(players.size()).is_equal(1)


func test_saving_again_replaces_the_key_of_a_player() -> void:
	var manager := TaloClaimKeyManager.new()
	manager.save_key("player-1", "first-key")
	manager.save_key("player-1", "second-key")

	assert_str(manager.get_player_key("player-1")).is_equal("second-key")
