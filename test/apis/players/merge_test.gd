extends GdUnitTestSuite

var _saved_client: TaloClient
var _saved_alias: TaloPlayerAlias
var _client: TaloFixtures.StubClient


func before_test() -> void:
	_saved_client = Talo.players.client
	_saved_alias = Talo.current_alias

	Talo.current_alias = null
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)

	var client: TaloFixtures.StubClient = auto_free(TaloFixtures.StubClient.new())
	_client = client
	Talo.players.client = _client


func after_test() -> void:
	Talo.players.client = _saved_client
	Talo.current_alias = _saved_alias
	Talo.claim_key_manager.clear_current_key()

	# gdlint-ignore-next-line private-access
	DirAccess.remove_absolute(TaloClaimKeyManager._CLAIM_KEY_PATH)


func test_sends_the_stored_key_of_the_second_player() -> void:
	Talo.claim_key_manager.save_key("player-2", "alice-key", "username", "alice")
	_client.responses.append(_merge_success())

	await Talo.players.merge("player-1", "player-2")

	var request := _client.requests[0]
	var body: Dictionary = request.body
	var sent_key: String = body.get("player2ClaimKey", "")

	assert_str(sent_key).is_equal("alice-key")


func test_adopts_the_key_the_surviving_player_inherited() -> void:
	Talo.current_alias = TaloFixtures.make_alias()
	Talo.claim_key_manager.save_key("player-2", "alice-key", "username", "alice")
	_client.responses.append(_merge_success())

	await Talo.players.merge("player-1", "player-2")

	assert_str(TaloClaimKeyManager.new().get_player_key("player-1")).is_equal("alice-key")
	assert_str(Talo.claim_key_manager.get_current_key(Talo.current_player)).is_equal("alice-key")


func test_forgets_the_merged_players_key() -> void:
	Talo.claim_key_manager.save_key("player-2", "alice-key", "username", "alice")
	_client.responses.append(
		_merge_success(
			[
				TaloFixtures.player_alias_factory(
					{ "player_alias": { "service": "username", "identifier": "alice" } }
				),
			]
		)
	)

	await Talo.players.merge("player-1", "player-2")

	var manager := TaloClaimKeyManager.new()
	assert_str(manager.get_player_key("player-2")).is_empty()
	# player-1 didn't have a key, so now they use player-2's key
	assert_str(manager.get_identify_key("username", "alice")).is_equal("alice-key")


func test_keeps_the_key_of_the_surviving_player() -> void:
	Talo.claim_key_manager.save_key("player-1", "bob-key", "username", "bob")
	Talo.claim_key_manager.save_key("player-2", "alice-key", "username", "alice")
	_client.responses.append(_merge_success())

	await Talo.players.merge("player-1", "player-2")

	assert_str(TaloClaimKeyManager.new().get_player_key("player-1")).is_equal("bob-key")


func _merge_success(aliases: Array = []) -> Dictionary:
	var player := TaloFixtures.player_factory()
	player.aliases = aliases

	return { status = 200, body = { player = player } }
