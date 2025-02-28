@tool
class_name TaloSettings

const _CATEGORY := "talo/"

const Settings = {
	ACCESS_KEY = "settings/access_key",
	API_URL = "settings/api_url",
	SOCKET_URL = "settings/socket_url",
	AUTO_CONNECT_SOCKET = "settings/auto_connect_socket",
	HANDLE_TREE_QUIT = "settings/handle_tree_quit",

	LOGGING_REQUESTS = "settings/logging/requests",
	LOGGING_RESPONSES = "settings/logging/responses",

	DEBUG_OFFLINE_MODE = "settings/debug/offline_mode",

	CONTINUITY_ENABLED = "settings/continuity/enabled",
}

const DEFAULT = {
	Settings.ACCESS_KEY: "",
	Settings.API_URL: "https://api.trytalo.com",
	Settings.SOCKET_URL: "wss://api.trytalo.com",
	Settings.AUTO_CONNECT_SOCKET: true,
	Settings.HANDLE_TREE_QUIT: true,

	Settings.LOGGING_REQUESTS: false,
	Settings.LOGGING_RESPONSES: false,

	Settings.DEBUG_OFFLINE_MODE: false,

	Settings.CONTINUITY_ENABLED: true,
}


static func add_setting(setting: String, default: Variant) -> void:
	assert(Engine.is_editor_hint())
	assert(Settings.values().has(setting))
	var key := _CATEGORY + setting
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, default)
	ProjectSettings.set_initial_value(key, default)
	ProjectSettings.set_as_basic(key, true)


static func set_setting(setting: String, value: Variant) -> void:
	assert(Settings.values().has(setting))
	var key := _CATEGORY + setting
	ProjectSettings.set_setting(key, value)


static func get_setting(setting: String, default: Variant = null) -> Variant:
	assert(Settings.values().has(setting))
	var key := _CATEGORY + setting
	if ProjectSettings.has_setting(key):
		return ProjectSettings.get_setting(key)
	if default != null:
		return default
	return DEFAULT[setting]
