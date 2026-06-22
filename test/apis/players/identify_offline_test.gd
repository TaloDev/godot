extends GdUnitTestSuite

var _saved_offline_mode: bool
var _saved_cache_setting: bool
var _saved_current_alias: TaloPlayerAlias

func before_test() -> void:
	_saved_offline_mode = Talo.settings.offline_mode
	Talo.settings.offline_mode = true

	_saved_cache_setting = Talo.settings.cache_player_on_identify
	Talo.settings.cache_player_on_identify = true

	_saved_current_alias = Talo.current_alias
	Talo.current_alias = null

	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)

func after_test() -> void:
	Talo.settings.offline_mode = _saved_offline_mode
	Talo.settings.cache_player_on_identify = _saved_cache_setting
	Talo.current_alias = _saved_current_alias

	DirAccess.remove_absolute(TaloPlayerAlias._OFFLINE_DATA_PATH)

func test_identifies_player_when_offline_with_matching_alias() -> void:
	var alias := TaloFixtures.make_alias({
		"player_alias": {
			"service": "talo",
			"identifier": "player1"
		}
	})
	alias.write_offline_alias()

	var player := await Talo.players.identify_offline("talo", "player1")

	assert_object(player).is_not_null()
	assert_object(Talo.current_alias).is_not_null()
	assert_str(Talo.current_alias.identifier).is_equal("player1")

func test_does_not_set_the_alias_on_request_mismatch() -> void:
	var alias := TaloFixtures.make_alias({
		"player_alias": {
			"service": "talo",
			"identifier": "player1"
		}
	})
	alias.write_offline_alias()

	var player := await Talo.players.identify_offline("talo", "wrong_player")

	assert_object(player).is_null()
	assert_object(Talo.current_alias).is_null()
