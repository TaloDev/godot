class_name TaloSettings extends RefCounted
## Talo's configuration options.
##
## @tutorial: https://docs.trytalo.com/docs/godot/settings-reference

var _config_file: ConfigFile

const SETTINGS_PATH := "res://addons/talo/settings.cfg"
const DEFAULT_API_URL := "https://api.trytalo.com"

const DEV_FEATURE_TAG := "talo_dev"
const LIVE_FEATURE_TAG := "talo_live"

## Your Talo access key, allowing you to connect to the Talo API and access data based on its scopes
var access_key: String:
	get:
		return _config_file.get_value("", "access_key", "")
	set(value):
		_config_file.set_value("", "access_key", value)

## The location of the Talo API
var api_url: String:
	get:
		return _config_file.get_value("", "api_url", DEFAULT_API_URL)
	set(value):
		_config_file.set_value("", "api_url", value)

## The location of the Talo Socket, starting with ws:// or wss://
var socket_url: String:
	get:
		return _config_file.get_value("", "socket_url", TaloSocket.DEFAULT_SOCKET_URL)
	set(value):
		_config_file.set_value("", "socket_url", value)

## If enabled, Talo will automatically connect to the Talo Socket when the game starts
var auto_connect_socket: bool:
	get:
		return _config_file.get_value("", "auto_connect_socket", true)
	set(value):
		_config_file.set_value("", "auto_connect_socket", value)

## Whether Talo should handle the tree quit request
var handle_tree_quit: bool:
	get:
		return _config_file.get_value("", "handle_tree_quit", true)
	set(value):
		_config_file.set_value("", "handle_tree_quit", value)

## If enabled, Talo will try to automatically replay failed network requests
var continuity_enabled: bool:
	get:
		return _config_file.get_value("continuity", "enabled", true)
	set(value):
		_config_file.set_value("continuity", "enabled", value)

## If enabled, requests to the Talo API will be logged to the console
var log_requests: bool:
	get:
		return _config_file.get_value("logging", "requests", false) and is_debug_build()
	set(value):
		_config_file.set_value("logging", "requests", value)

## If enabled, responses from the Talo API will be logged to the console
var log_responses: bool:
	get:
		return _config_file.get_value("logging", "responses", false) and is_debug_build()
	set(value):
		_config_file.set_value("logging", "responses", value)

## If enabled, Talo will simulate the player not having an internet connection
var offline_mode: bool:
	get:
		return _config_file.get_value("debug", "offline_mode", false)
	set(value):
		_config_file.set_value("debug", "offline_mode", value)

## If enabled and a valid session token is found, automatically authenticate the player
var auto_start_session: bool:
	get:
		return _config_file.get_value("player_auth", "auto_start_session", true)
	set(value):
		_config_file.set_value("player_auth", "auto_start_session", value)

## If enabled, Talo will automatically cache the player after a successful online identification
## If the player is offline and tries to identify in later sessions, Talo will attempt to use the cached the player data
var cache_player_on_identify: bool:
	get:
		return _config_file.get_value("", "cache_player_on_identify", true)
	set(value):
		_config_file.set_value("", "cache_player_on_identify", value)

func _init() -> void:
	_config_file = ConfigFile.new()

	if not FileAccess.file_exists(SETTINGS_PATH):
		# set each setting to their default value
		access_key = access_key
		api_url = api_url
		socket_url = socket_url
		auto_connect_socket = auto_connect_socket
		handle_tree_quit = handle_tree_quit
		continuity_enabled = continuity_enabled
		auto_start_session = auto_start_session
		cache_player_on_identify = cache_player_on_identify
		save_config()

		print_rich("[color=green]Talo settings.cfg created! Please close the game and fill in your access_key.[/color]")
	else:
		_config_file.load(SETTINGS_PATH)

		if access_key.is_empty() and is_debug_build():
			print_rich("[color=yellow]Warning: Talo access_key in settings.cfg is empty[/color]")

func is_debug_build() -> bool:
	if OS.has_feature(LIVE_FEATURE_TAG):
		return false
	if OS.has_feature(DEV_FEATURE_TAG):
		return true
	return OS.is_debug_build() 

## Save the Talo settings to the config file
func save_config():
	if _config_file == null:
		return
	_config_file.save(SETTINGS_PATH)
