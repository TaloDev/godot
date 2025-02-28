extends Node

signal init_completed

var current_alias: TaloPlayerAlias
var current_player: TaloPlayer:
	get:
		return null if not current_alias else current_alias.player

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
	_check_access_key()
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

	if Talo.get_setting(Talo.Settings.AUTO_CONNECT_SOCKET):
		socket.open_connection()

func _notification(what: int):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_do_flush()
			if Talo.get_setting(Talo.Settings.HANDLE_TREE_QUIT):
				get_tree().quit()
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			_do_flush()

func _check_access_key() -> void:
	if OS.is_debug_build() and get_setting(Settings.ACCESS_KEY).is_empty():
		print_rich("[color=yellow]Warning: Talo access_key in \"ProjectSettings\" is empty.[/color]")

func _load_apis() -> void:
	players = preload("res://addons/talo/apis/players_api.gd").new("/v1/players")
	events = preload("res://addons/talo/apis/events_api.gd").new("/v1/events")
	game_config = preload("res://addons/talo/apis/game_config_api.gd").new("/v1/game-config")
	stats = preload("res://addons/talo/apis/stats_api.gd").new("/v1/game-stats")
	leaderboards = preload("res://addons/talo/apis/leaderboards_api.gd").new("/v1/leaderboards")
	saves = preload("res://addons/talo/apis/saves_api.gd").new("/v1/game-saves")
	feedback = preload("res://addons/talo/apis/feedback_api.gd").new("/v1/game-feedback")
	player_auth = preload("res://addons/talo/apis/player_auth_api.gd").new("/v1/players/auth")
	health_check = preload("res://addons/talo/apis/health_check_api.gd").new("/v1/health-check")
	player_groups = preload("res://addons/talo/apis/player_groups_api.gd").new("/v1/player-groups")
	channels = preload("res://addons/talo/apis/channels_api.gd").new("/v1/game-channels")
	socket_tickets = preload("res://addons/talo/apis/socket_tickets_api.gd").new("/v1/socket-tickets")
	player_presence = preload("res://addons/talo/apis/player_presence_api.gd").new("/v1/players/presence")

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
	return get_setting(Settings.DEBUG_OFFLINE_MODE)

func is_offline() -> bool:
	return offline_mode_enabled() or not await health_check.ping()

func _do_flush() -> void:
	if identity_check(false) == OK:
		events.flush()

func _check_session() -> void:
	var session_token = player_auth.session_manager.get_token()
	if not session_token.is_empty():
		players.identify("talo", player_auth.session_manager.get_identifier())

# region Settings
const Settings = TaloSettings.Settings

static func set_setting(setting: String, value: Variant) -> void:
	TaloSettings.set_setting(setting, value)

static func get_setting(setting: String) -> Variant:
	return TaloSettings.get_setting(setting)
# endregion Settings
