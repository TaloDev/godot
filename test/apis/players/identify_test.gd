extends GdUnitTestSuite


class StubHealthCheck extends HealthCheckAPI:
	func _init() -> void:
		super("/public/health")


	func ping() -> bool:
		return true


var _saved_client: TaloClient
var _saved_health_check: HealthCheckAPI
var _saved_alias: TaloPlayerAlias
var _saved_cache_setting: bool
var _saved_offline_mode: bool

var _client: TaloFixtures.StubClient
var _identify_errors: Array[TaloIdentifyError] = []


func before_test() -> void:
	_saved_client = Talo.players.client
	_saved_health_check = Talo.health_check
	_saved_alias = Talo.current_alias
	_saved_cache_setting = Talo.settings.cache_player_on_identify
	_saved_offline_mode = Talo.settings.offline_mode

	Talo.settings.offline_mode = false
	Talo.settings.cache_player_on_identify = true
	Talo.current_alias = null
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)

	var client: TaloFixtures.StubClient = auto_free(TaloFixtures.StubClient.new())
	_client = client
	Talo.players.client = _client

	# added to the tree so the health check's debounce timer is freed with it
	var health_check: StubHealthCheck = auto_free(StubHealthCheck.new())
	add_child(health_check)
	Talo.health_check = health_check

	Talo.players.identification_failed.connect(_on_identification_failed)


func after_test() -> void:
	Talo.players.identification_failed.disconnect(_on_identification_failed)
	Talo.players.client = _saved_client
	Talo.health_check = _saved_health_check
	Talo.current_alias = _saved_alias
	Talo.settings.cache_player_on_identify = _saved_cache_setting
	Talo.settings.offline_mode = _saved_offline_mode
	_identify_errors.clear()

	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)
	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)


func test_identifies_with_a_claim_key() -> void:
	_client.responses.append(_identify_success())

	var alias := await Talo.players.identify("username", "bob", "caller-key")
	assert_object(alias).is_not_null()
	if is_failure():
		return

	var request := _request(0)
	var method: int = request.method
	var url: String = request.url
	var body: Dictionary = request.body
	var service: String = body.service
	var identifier: String = body.identifier

	assert_int(method).is_equal(HTTPClient.METHOD_POST)
	assert_str(url).is_equal("/identify")
	assert_str(service).is_equal("username")
	assert_str(identifier).is_equal("bob")
	assert_str(_claim_key_header(0)).is_equal("caller-key")
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("caller-key")
	assert_str(TaloClaimKeyManager.new().get_player_key(alias.player.id)).is_equal("caller-key")


func test_identifies_without_a_claim_key() -> void:
	_client.responses.append(_identify_success())

	var alias := await Talo.players.identify("username", "bob")
	assert_object(alias).is_not_null()
	if is_failure():
		return

	assert_str(_claim_key_header(0)).is_empty()
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_empty()
	assert_str(TaloClaimKeyManager.new().get_player_key(alias.player.id)).is_empty()


func test_reuses_the_stored_key_when_the_game_passes_none() -> void:
	_client.responses.append(_identify_success())
	await Talo.players.identify("username", "bob", "caller-key")

	Talo.player_auth.session_manager.clear_session(false)

	_client.responses.append(_identify_success())
	await Talo.players.identify("username", "bob")

	assert_str(_claim_key_header(1)).is_equal("caller-key")
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("caller-key")


func test_reuses_the_stored_key_when_offline() -> void:
	var offline_alias := TaloFixtures.make_alias(
		{ "player_alias": { "service": "username", "identifier": "bob" } }
	)
	offline_alias.write_offline_alias()
	Talo.claim_key_manager.save_key("player-1", "caller-key", "username", "bob")
	Talo.settings.offline_mode = true

	var alias := await Talo.players.identify("username", "bob")
	assert_object(alias).is_not_null()
	if is_failure():
		return

	assert_int(_client.requests.size()).is_equal(0)
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("caller-key")


func test_saves_the_resolved_identifier_of_an_integration() -> void:
	# steam answers with the resolved steam id, never with the ticket that was sent
	_client.responses.append(_identify_success("76561198000000000", "steam"))

	await Talo.players.identify("steam", "ticket-1", "caller-key")

	var manager := TaloClaimKeyManager.new()
	assert_str(manager.get_player_key("player-1")).is_equal("caller-key")
	assert_str(manager.get_identify_key("steam", "76561198000000000")).is_equal("caller-key")
	assert_str(manager.get_identify_key("steam", "ticket-1")).is_empty()


func test_stores_the_identity_the_backend_resolved() -> void:
	# the backend trims and lowercases the service and keeps the trimmed identifier
	_client.responses.append(_identify_success("bob", "username"))

	await Talo.players.identify(" Username ", " bob ", "caller-key")

	# the next launch identifies the same way, so the lookup must land on the stored entry
	assert_str(TaloClaimKeyManager.new().get_identify_key(" Username ", " bob ")).is_equal(
		"caller-key"
	)


func test_a_rejected_claim_key_does_not_clear_the_identity() -> void:
	# establish a player and its key, then reject a different key for the same player
	_client.responses.append(_identify_success())
	await Talo.players.identify("username", "bob", "old-key")

	_client.responses.append(
		{
			status = HTTPClient.RESPONSE_UNAUTHORIZED,
			body = { errorCode = "INVALID_CLAIM_KEY", message = "missing or invalid claim key" },
		}
	)

	var alias := await Talo.players.identify("username", "bob", "wrong-key")

	# any other identify failure clears the identity, this one must leave it and its key alone
	assert_object(alias).is_null()
	assert_object(Talo.current_alias).is_not_null()
	assert_int(_client.requests.size()).is_equal(2)
	assert_int(_identify_errors.size()).is_equal(1)
	assert_int(_identify_errors[0].code).is_equal(TaloIdentifyError.ErrorCode.INVALID_CLAIM_KEY)
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("old-key")
	assert_str(TaloClaimKeyManager.new().get_player_key("player-1")).is_equal("old-key")


func test_identifying_another_player_sends_no_claim_key() -> void:
	# bob keeps the identity while the game resolves alice, whose key is not known yet
	_client.responses.append(_identify_success())
	await Talo.players.identify("username", "bob", "bobs-key")

	_client.responses.append(_identify_success("alice", "username"))
	await Talo.players.identify("username", "alice")

	# bob's key must not be sent on the request that names alice
	var request := _request(1)
	assert_object(request.identity).is_null()
	assert_str(_claim_key_header(1)).is_empty()


func _identify_success(identifier := "bob", service := "username") -> Dictionary:
	var alias := TaloFixtures.player_alias_factory(
		{ "player_alias": { "service": service, "identifier": identifier } }
	)
	return { status = 200, body = { alias = alias, socketToken = "" } }


func _request(index: int) -> Dictionary:
	if index >= _client.requests.size():
		return { }

	return _client.requests[index]


func _claim_key_header(index: int) -> String:
	var request := _request(index)
	if request.is_empty():
		return ""

	var headers: Array[String] = request.headers
	var prefix := "%s: " % TaloClaimKeyManager.HEADER
	for header in headers:
		if header.begins_with(prefix):
			return header.trim_prefix(prefix)

	return ""


func _on_identification_failed(error: TaloIdentifyError) -> void:
	_identify_errors.append(error)
