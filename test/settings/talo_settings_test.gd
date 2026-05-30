extends GdUnitTestSuite

var _saved_access_key: String
var _saved_api_url: String
var _saved_socket_url: String
var _file_backup := ConfigFile.new()
var _had_config_file := false

func before() -> void:
	_saved_access_key = Talo.settings._config_file.get_value("", "access_key", "")
	_saved_api_url = Talo.settings._config_file.get_value("", "api_url", TaloSettings.DEFAULT_API_URL)
	_saved_socket_url = Talo.settings._config_file.get_value("", "socket_url", TaloSocket.DEFAULT_SOCKET_URL)

	_had_config_file = FileAccess.file_exists(TaloSettings.SETTINGS_PATH)
	if _had_config_file:
		_file_backup.load(TaloSettings.SETTINGS_PATH)

	Talo.settings._config_file.set_value("", "access_key", "")
	Talo.settings._config_file.set_value("", "api_url", TaloSettings.DEFAULT_API_URL)
	Talo.settings._config_file.set_value("", "socket_url", TaloSocket.DEFAULT_SOCKET_URL)

func after() -> void:
	Talo.settings._config_file.set_value("", "access_key", _saved_access_key)
	Talo.settings._config_file.set_value("", "api_url", _saved_api_url)
	Talo.settings._config_file.set_value("", "socket_url", _saved_socket_url)

	if _had_config_file:
		_file_backup.save(TaloSettings.SETTINGS_PATH)
	elif FileAccess.file_exists(TaloSettings.SETTINGS_PATH):
		DirAccess.remove_absolute(TaloSettings.SETTINGS_PATH)

# access_key

func test_access_key_defaults_to_empty() -> void:
	assert_str(Talo.settings.access_key).is_empty()

func test_access_key_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "access_key", "test-key")
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_str(Talo.settings.access_key).is_equal("test-key")

func test_access_key_writing() -> void:
	Talo.settings.access_key = "persisted-key"
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_str(file.get_value("", "access_key", "")).is_equal("persisted-key")

# api_url

func test_api_url_defaults_to_default_api_url() -> void:
	assert_str(Talo.settings.api_url).is_equal(TaloSettings.DEFAULT_API_URL)

func test_api_url_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "api_url", "http://localhost:9999")
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_str(Talo.settings.api_url).is_equal("http://localhost:9999")

func test_api_url_writing() -> void:
	Talo.settings.api_url = "https://custom.api.com"
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_str(file.get_value("", "api_url", "")).is_equal("https://custom.api.com")

# socket_url

func test_socket_url_defaults_to_default_socket_url() -> void:
	assert_str(Talo.settings.socket_url).is_equal(TaloSocket.DEFAULT_SOCKET_URL)

func test_socket_url_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "socket_url", "ws://localhost:9999")
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_str(Talo.settings.socket_url).is_equal("ws://localhost:9999")

func test_socket_url_writing() -> void:
	Talo.settings.socket_url = "wss://custom.socket.com"
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_str(file.get_value("", "socket_url", "")).is_equal("wss://custom.socket.com")

# auto_connect_socket

func test_auto_connect_socket_defaults_to_true() -> void:
	assert_bool(Talo.settings.auto_connect_socket).is_true()

func test_auto_connect_socket_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "auto_connect_socket", false)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.auto_connect_socket).is_false()

func test_auto_connect_socket_writing() -> void:
	Talo.settings.auto_connect_socket = false
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("", "auto_connect_socket", true)).is_false()

# handle_tree_quit

func test_handle_tree_quit_defaults_to_true() -> void:
	assert_bool(Talo.settings.handle_tree_quit).is_true()

func test_handle_tree_quit_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "handle_tree_quit", false)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.handle_tree_quit).is_false()

func test_handle_tree_quit_writing() -> void:
	Talo.settings.handle_tree_quit = false
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("", "handle_tree_quit", true)).is_false()

# continuity_enabled

func test_continuity_enabled_defaults_to_true() -> void:
	assert_bool(Talo.settings.continuity_enabled).is_true()

func test_continuity_enabled_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("continuity", "enabled", false)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.continuity_enabled).is_false()

func test_continuity_enabled_writing() -> void:
	Talo.settings.continuity_enabled = false
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("continuity", "enabled", true)).is_false()

# log_requests (getter: config_value AND is_debug_build, so roundtrip and file tests only)

func test_log_requests_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("logging", "requests", true)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.log_requests).is_true()

func test_log_requests_writing() -> void:
	Talo.settings.log_requests = true
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("logging", "requests", false)).is_true()

# log_responses (getter: config_value AND is_debug_build, so roundtrip and file tests only)

func test_log_responses_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("logging", "responses", true)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.log_responses).is_true()

func test_log_responses_writing() -> void:
	Talo.settings.log_responses = true
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("logging", "responses", false)).is_true()

# offline_mode

func test_offline_mode_defaults_to_false() -> void:
	assert_bool(Talo.settings.offline_mode).is_false()

func test_offline_mode_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("debug", "offline_mode", true)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.offline_mode).is_true()

func test_offline_mode_writing() -> void:
	Talo.settings.offline_mode = true
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("debug", "offline_mode", false)).is_true()

# auto_start_session

func test_auto_start_session_defaults_to_true() -> void:
	assert_bool(Talo.settings.auto_start_session).is_true()

func test_auto_start_session_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("player_auth", "auto_start_session", false)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.auto_start_session).is_false()

func test_auto_start_session_writing() -> void:
	Talo.settings.auto_start_session = false
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("player_auth", "auto_start_session", true)).is_false()

# cache_player_on_identify

func test_cache_player_on_identify_defaults_to_true() -> void:
	assert_bool(Talo.settings.cache_player_on_identify).is_true()

func test_cache_player_on_identify_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "cache_player_on_identify", false)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.cache_player_on_identify).is_false()

func test_cache_player_on_identify_writing() -> void:
	Talo.settings.cache_player_on_identify = false
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("", "cache_player_on_identify", true)).is_false()

# debounce_timer_seconds

func test_debounce_timer_seconds_defaults_to_1() -> void:
	assert_float(Talo.settings.debounce_timer_seconds).is_equal(1.0)

func test_debounce_timer_seconds_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("", "debounce_timer_seconds", 2.5)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_float(Talo.settings.debounce_timer_seconds).is_equal(2.5)

func test_debounce_timer_seconds_writing() -> void:
	Talo.settings.debounce_timer_seconds = 2.5
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_float(file.get_value("", "debounce_timer_seconds", 1.0)).is_equal(2.5)

# verification_enabled

func test_verification_enabled_defaults_to_false() -> void:
	assert_bool(Talo.settings.verification_enabled).is_false()

func test_verification_enabled_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("verification", "enabled", true)
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(Talo.settings.verification_enabled).is_true()

func test_verification_enabled_writing() -> void:
	Talo.settings.verification_enabled = true
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_bool(file.get_value("verification", "enabled", false)).is_true()

# verification_key_version

func test_verification_key_version_defaults_to_empty() -> void:
	assert_str(Talo.settings.verification_key_version).is_empty()

func test_verification_key_version_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("verification", "key_version", "2")
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_str(Talo.settings.verification_key_version).is_equal("2")

func test_verification_key_version_writing() -> void:
	Talo.settings.verification_key_version = "3"
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_str(file.get_value("verification", "key_version", "")).is_equal("3")

# verification_key_value

func test_verification_key_value_defaults_to_empty() -> void:
	assert_str(Talo.settings.verification_key_value).is_empty()

func test_verification_key_value_reading() -> void:
	var file := ConfigFile.new()
	file.set_value("verification", "key_value", "my-secret-key")
	file.save(TaloSettings.SETTINGS_PATH)
	Talo.settings._config_file.load(TaloSettings.SETTINGS_PATH)
	assert_str(Talo.settings.verification_key_value).is_equal("my-secret-key")

func test_verification_key_value_writing() -> void:
	Talo.settings.verification_key_value = "persisted-secret"
	Talo.settings.save_config()
	var file := ConfigFile.new()
	file.load(TaloSettings.SETTINGS_PATH)
	assert_str(file.get_value("verification", "key_value", "")).is_equal("persisted-secret")
