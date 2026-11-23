extends GdUnitTestSuite

const MIGRATED_IDENTIFIER := "76561198000000000"

var _saved_client: TaloClient
var _saved_alias: TaloPlayerAlias
var _saved_cache_setting: bool
var _client: TaloFixtures.StubClient


func before_test() -> void:
	_saved_client = Talo.player_auth.client
	_saved_alias = Talo.current_alias
	_saved_cache_setting = Talo.settings.cache_player_on_identify

	Talo.settings.cache_player_on_identify = true
	Talo.current_alias = TaloFixtures.make_alias()
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)

	var client: TaloFixtures.StubClient = auto_free(TaloFixtures.StubClient.new())
	_client = client
	Talo.player_auth.client = _client


func after_test() -> void:
	Talo.player_auth.client = _saved_client
	Talo.current_alias = _saved_alias
	Talo.settings.cache_player_on_identify = _saved_cache_setting
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)


func test_sends_the_key_and_saves_it_for_the_migrated_identity() -> void:
	_client.responses.append(_migrate_success())

	var result := await Talo.player_auth.migrate_account(
		"password",
		"steam",
		MIGRATED_IDENTIFIER,
		"caller-key",
	)

	assert_bool(result.success).is_true()

	var request := _request(0)
	var headers: Array[String] = request.headers
	assert_array(headers).contains(["X-Talo-Claim-Key: caller-key"])

	var manager := TaloClaimKeyManager.new()
	assert_str(manager.get_player_key("player-1")).is_equal("caller-key")
	assert_str(manager.get_identify_key("steam", MIGRATED_IDENTIFIER)).is_equal("caller-key")
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("caller-key")


func test_files_the_key_under_the_identity_the_backend_stored() -> void:
	# the backend resolves a ticket to the steam id, so the request values are never stored again
	_client.responses.append(_migrate_success())

	await Talo.player_auth.migrate_account("password", " Steam ", " ticket-1 ", "caller-key")

	var manager := TaloClaimKeyManager.new()
	assert_str(manager.get_identify_key("steam", MIGRATED_IDENTIFIER)).is_equal("caller-key")
	assert_str(manager.get_identify_key("steam", "ticket-1")).is_empty()


func _migrate_success() -> Dictionary:
	var alias := TaloFixtures.player_alias_factory(
		{ "player_alias": { "service": "steam", "identifier": MIGRATED_IDENTIFIER } }
	)
	return { status = 200, body = { alias = alias } }


func _request(index: int) -> Dictionary:
	if index >= _client.requests.size():
		return { }

	return _client.requests[index]
