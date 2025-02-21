extends Node

signal init_completed

const PlayersAPI = preload("apis/players_api.gd")
const EventsAPI = preload("apis/events_api.gd")
const GameConfigAPI = preload("apis/game_config_api.gd")
const StatsAPI = preload("apis/stats_api.gd")
const LeaderboardsAPI = preload("apis/leaderboards_api.gd")
const SavesAPI = preload("apis/saves_api.gd")
const FeedbackAPI = preload("apis/feedback_api.gd")
const PlayerAuthAPI = preload("apis/player_auth_api.gd")
const HealthCheckAPI = preload("apis/health_check_api.gd")
const PlayerGroupsAPI = preload("apis/player_groups_api.gd")
const ChannelsAPI = preload("apis/channels_api.gd")
const SocketTicketsAPI = preload("apis/socket_tickets_api.gd")
const PlayerPresenceAPI = preload("apis/player_presence_api.gd")

var current_alias: TaloPlayerAlias
var current_player: TaloPlayer:
	get:
		return null if not current_alias else current_alias.player

var settings: ConfigFile

# APIs
var players: PlayersAPI
var events: EventsAPI
var game_config: GameConfigAPI
var stats: StatsAPI
var leaderboards: LeaderboardsAPI
var saves: SavesAPI
var feedback: FeedbackAPI
var player_auth: PlayerAuthAPI
var health_check: HealthCheckAPI
var player_groups: PlayerGroupsAPI
var channels: ChannelsAPI
var socket_tickets: SocketTicketsAPI
var player_presence: PlayerPresenceAPI

var live_config: TaloLiveConfig

var crypto_manager: TaloCryptoManager
var continuity_manager: TaloContinuityManager

var socket: TaloSocket

func _ready() -> void:
	_load_config()
	_load_apis()
	_init_crypto_manager()
	_init_continuity()
	_init_socket()
	_check_session()

	get_tree().set_auto_accept_quit(false)
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	init_completed.emit()

func _init_crypto_manager() -> void:
	crypto_manager = TaloCryptoManager.new()

func _init_continuity() -> void:
	continuity_manager = TaloContinuityManager.new()
	add_child(continuity_manager)

func _init_socket() -> void:
	socket = TaloSocket.new()
	add_child(socket)

	if Talo.settings.get_value("", "auto_connect_socket", true):
		socket.open_connection()

func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_do_flush()
			if Talo.settings.get_value("", "handle_tree_quit", true):
				get_tree().quit()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			_do_flush()

func _load_config() -> void:
	var settings_path = "res://addons/talo/settings.cfg"
	settings = ConfigFile.new()

	if not FileAccess.file_exists(settings_path):
		settings.set_value("", "access_key", "")
		settings.set_value("", "api_url", "https://api.trytalo.com")
		settings.set_value("", "socket_url", TaloSocket.default_socket_url)
		settings.set_value("", "auto_connect_socket", true)
		settings.set_value("", "handle_tree_quit", true)
		settings.set_value("continuity", "enabled", true)
		settings.save(settings_path)

		print_rich("[color=green]Talo settings.cfg created! Please close the game and fill in your access_key.[/color]")
	else:
		settings.load(settings_path)

		if (settings.get_value("", "access_key", "").is_empty()) && OS.is_debug_build():
			print_rich("[color=yellow]Warning: Talo access_key in settings.cfg is empty[/color]")

func _load_apis() -> void:
	players = PlayersAPI.new("/v1/players")
	events = EventsAPI.new("/v1/events")
	game_config = GameConfigAPI.new("/v1/game-config")
	stats = StatsAPI.new("/v1/game-stats")
	leaderboards = LeaderboardsAPI.new("/v1/leaderboards")
	saves = SavesAPI.new("/v1/game-saves")
	feedback = FeedbackAPI.new("/v1/game-feedback")
	player_auth = PlayerAuthAPI.new("/v1/players/auth")
	health_check = HealthCheckAPI.new("/v1/health-check")
	player_groups = PlayerGroupsAPI.new("/v1/player-groups")
	channels = ChannelsAPI.new("/v1/game-channels")
	socket_tickets = SocketTicketsAPI.new("/v1/socket-tickets")
	player_presence = PlayerPresenceAPI.new("/v1/players/presence")

	for api in [
		players,
		events,
		game_config,
		stats,
		leaderboards,
		saves,
		feedback,
		player_auth,
		health_check,
		player_groups,
		channels,
		socket_tickets,
		player_presence
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

func offline_mode_enabled() -> bool:
	return settings.get_value("debug", "offline_mode", false)

func is_offline() -> bool:
	return offline_mode_enabled() or not await health_check.ping()

func _do_flush() -> void:
	if identity_check(false) == OK:
		events.flush()

func _check_session() -> void:
	var session_token = player_auth.session_manager.get_token()
	if not session_token.is_empty():
		players.identify("talo", player_auth.session_manager.get_identifier())
