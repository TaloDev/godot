extends Node

var current_alias: TaloPlayerAlias
var current_player: TaloPlayer:
	get:
		return null if not current_alias else current_alias.player

var config: ConfigFile

var players: PlayersAPI
var events: EventsAPI
var game_config: GameConfigAPI
var stats: StatsAPI
var leaderboards: LeaderboardsAPI
var saves: SavesAPI
var feedback: FeedbackAPI
var player_auth: PlayerAuthAPI

var live_config: TaloLiveConfig

func _ready() -> void:
	_load_config()
	_load_apis()
	_check_session()
	get_tree().set_auto_accept_quit(false)

func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_do_flush()
			get_tree().quit()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			_do_flush()

func _load_config() -> void:
	var settings_path = "res://addons/talo/settings.cfg"
	config = ConfigFile.new()

	if not FileAccess.file_exists(settings_path):
		config.set_value("", "access_key", "")
		config.set_value("", "api_url", "https://api.trytalo.com")
		config.save(settings_path)
	else:
		config.load(settings_path)
	
func _load_apis() -> void:
	players = preload("res://addons/talo/apis/players_api.gd").new("/v1/players")
	events = preload("res://addons/talo/apis/events_api.gd").new("/v1/events")
	game_config = preload("res://addons/talo/apis/game_config_api.gd").new("/v1/game-config")
	stats = preload("res://addons/talo/apis/stats_api.gd").new("/v1/game-stats")
	leaderboards = preload("res://addons/talo/apis/leaderboards_api.gd").new("/v1/leaderboards")
	saves = preload("res://addons/talo/apis/saves_api.gd").new("/v1/game-saves")
	feedback = preload("res://addons/talo/apis/feedback_api.gd").new("/v1/game-feedback")
	player_auth = preload("res://addons/talo/apis/player_auth_api.gd").new("/v1/players/auth")
	
	for api in [
		players,
		events,
		game_config,
		stats,
		leaderboards,
		saves,
		feedback,
		player_auth
	]:
		add_child(api)

func has_identity() -> bool:
	return current_alias != null

func identity_check(should_error = true) -> Error:
	if not has_identity():
		if should_error:
			push_error("You need to identify a player using Talo.players.identify() before doing this")
		return ERR_UNAUTHORIZED

	return OK

func is_offline() -> bool:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	http_request.request("https://httpbin.org/get")
	var res = await http_request.request_completed
	http_request.queue_free()

	return res[0] != OK

func _do_flush() -> void:
	if identity_check(false) == OK:
		Talo.events.flush()

func _check_session() -> void:
	var session_token = player_auth.session_manager.load_session()
	if not session_token.is_empty():
		Talo.players.identify('talo', player_auth.session_manager.get_identifier())
