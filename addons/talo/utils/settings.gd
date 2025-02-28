@tool
class_name TaloSettings

const ACCESS_KEY_PATH = "res://talo_access_key.txt"

const _CATEGORY := "talo/"

const Settings = {
	ACCESS_KEY = "common/access_key",

	API_URL = "common/api_url",
	SOCKET_URL = "common/socket_url",
	AUTO_CONNECT_SOCKET = "common/auto_connect_socket",
	HANDLE_TREE_QUIT = "common/handle_tree_quit",

	LOGGING_REQUESTS = "logging/requests",
	LOGGING_RESPONSES = "logging/responses",

	DEBUG_OFFLINE_MODE = "debug/offline_mode",

	CONTINUITY_ENABLED = "continuity/enabled",
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


static func migrate_old_settings() -> void:
	assert(Engine.is_editor_hint())
	const old_settings_path := "res://addons/talo/settings.cfg"
	if not FileAccess.file_exists(old_settings_path):
		return
	var cfg := ConfigFile.new()
	var err := cfg.load(old_settings_path)
	if err != OK:
		push_error("Migrate settings from old \"settings.cfg\" failed: %s"%error_string(err))
		return

	for section in cfg.get_sections():
		var validated_section := "common" if section.is_empty() else section
		for key in cfg.get_section_keys(section):
			var setting := ("%s/%s" % [validated_section, key])
			if not setting in Settings.values():
				push_warning("Skip unrecognized setting \"%s\"" % setting.trim_prefix("common/"))
				continue

			var value := cfg.get_value(section, key)
			set_setting(setting, value)

	OS.move_to_trash(ProjectSettings.globalize_path(old_settings_path))
	print_rich("[color=green]Migrate Talo settings from \"settings.cfg\" to ProjectSettings finished. You can recover the old settings file from system's recycle bin.[/color]")


static func add_setting(setting: String, default: Variant) -> void:
	assert(Engine.is_editor_hint())
	assert(Settings.values().has(setting))
	if setting == Settings.ACCESS_KEY:
		if not FileAccess.file_exists(ACCESS_KEY_PATH):
			var f := FileAccess.open(ACCESS_KEY_PATH, FileAccess.WRITE)
			assert(is_instance_valid(f), "Create \"%s\" failed: %s" % [ACCESS_KEY_PATH, error_string(FileAccess.get_open_error())])
			f.store_string(DEFAULT[Settings.ACCESS_KEY])
		return

	var key := _CATEGORY + setting
	if not ProjectSettings.has_setting(key):
		ProjectSettings.set_setting(key, default)
	ProjectSettings.set_initial_value(key, default)
	ProjectSettings.set_as_basic(key, true)


static func set_setting(setting: String, value: Variant) -> void:
	assert(Settings.values().has(setting))
	if setting == Settings.ACCESS_KEY:
		assert(Engine.is_editor_hint())
		var f := FileAccess.open(ACCESS_KEY_PATH, FileAccess.WRITE)
		assert(is_instance_valid(f), "Open \"%s\" failed: %s" % [ACCESS_KEY_PATH, error_string(FileAccess.get_open_error())])
		f.store_string(value)
		return

	var key := _CATEGORY + setting
	ProjectSettings.set_setting(key, value)


static var _access_key: String # Cache for runtime.

static func get_setting(setting: String, default: Variant = null) -> Variant:
	assert(Settings.values().has(setting))
	if setting == Settings.ACCESS_KEY:
		if _access_key.is_empty() or Engine.is_editor_hint():
			if FileAccess.file_exists(ACCESS_KEY_PATH):
				_access_key = FileAccess.get_file_as_string(ACCESS_KEY_PATH)
			else:
				_access_key = DEFAULT[Settings.ACCESS_KEY]
		return _access_key

	var key := _CATEGORY + setting
	if ProjectSettings.has_setting(key):
		return ProjectSettings.get_setting(key)
	if default != null:
		return default
	return DEFAULT[setting]
