class_name EventsAPI extends TaloAPI

var _queue = []
var _min_queue_size = 10

func _get_window_mode() -> String:
	match DisplayServer.window_get_mode():
		Window.MODE_EXCLUSIVE_FULLSCREEN: return "Exclusive fullscreen"
		Window.MODE_FULLSCREEN: return "Fullscreen window"
		Window.MODE_MAXIMIZED: return "Maximized window"
		Window.MODE_WINDOWED: return "Windowed"
		_: return ""

func _get_game_version() -> String:
	var export_config = ConfigFile.new()
	var export_config_path = "res://export_presets.cfg"
	var config_error = export_config.load(export_config_path)
	return "" if config_error else export_config.get_value("preset.0.options", "application/product_version")

func _build_meta_props() -> Array[TaloProp]:
	return [
		TaloProp.new("META_OS", OS.get_name()),
		TaloProp.new("META_GAME_VERSION", _get_game_version()),
		TaloProp.new("META_WINDOW_MODE", _get_window_mode()),
		TaloProp.new("META_SCREEN_WIDTH", str(DisplayServer.window_get_size().x)),
		TaloProp.new("META_SCREEN_HEIGHT", str(DisplayServer.window_get_size().y))
	]

func _has_errors(errors: Array) -> bool:
	return errors.any((func (err: Array): return err.size() > 0))

func track(name: String, props: Dictionary) -> void:
	Talo.identity_check()

	var final_props = _build_meta_props()
	final_props.append_array(
		props
			.keys()
			.map(func (key: String): return TaloProp.new(key, str(props[key])))
	)

	_queue.push_back({
		name = name,
		props = final_props.map(func (prop: TaloProp): return prop.to_dictionary()),
		timestamp = ceil(Time.get_unix_time_from_system()) * 1000
	})

	if _queue.size() >= _min_queue_size:
		var res = await client.make_request(HTTPClient.METHOD_POST, "/", { events = _queue })

		match (res.status):
			200:
				if not _has_errors(res.body.errors):
					_queue.clear()
				else:
					client.handle_error(res)
