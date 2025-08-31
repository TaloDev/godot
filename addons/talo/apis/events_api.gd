class_name EventsAPI extends TaloAPI
## An interface for communicating with the Talo Events API.
##
## This API is used to track events in your game. Events are used to measure user interactions such as button clicks, level completions and other kinds of game interactions.
##
## @tutorial: https://docs.trytalo.com/docs/godot/events

var _queue := []
var _min_queue_size := 10

var _events_to_flush := []
var _lock_flushes := false
var _flush_attempted_during_lock := false

func _get_window_mode() -> String:
	match DisplayServer.window_get_mode():
		Window.MODE_EXCLUSIVE_FULLSCREEN: return "Exclusive fullscreen"
		Window.MODE_FULLSCREEN: return "Fullscreen window"
		Window.MODE_MAXIMIZED: return "Maximized window"
		Window.MODE_WINDOWED: return "Windowed"
		_: return ""

func _get_game_version() -> String:
	return ProjectSettings.get_setting("application/config/version")

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

## Track an event with optional props (key-value pairs) and add it to the queue of events ready to be sent to the backend. If the queue reaches the minimum size, it will be flushed.
func track(name: String, props: Dictionary[String, String] = {}) -> void:
	if Talo.identity_check() != OK:
		return

	var final_props := _build_meta_props()
	final_props.append_array(TaloPropUtils.dictionary_to_prop_array(props))

	_queue.push_back({
		name = name,
		props = TaloPropUtils.serialise_prop_array(final_props),
		timestamp = TaloTimeUtils.get_timestamp_msec()
	})

	if _queue.size() >= _min_queue_size:
		await flush()

## Flush the current queue of events. This is called automatically when the queue reaches the minimum size.
func flush() -> void:
	if _queue.size() == 0:
		return

	if _lock_flushes:
		_flush_attempted_during_lock = true
		return

	_lock_flushes = true
	_events_to_flush.append_array(_queue)
	_queue.clear()

	var res := await client.make_request(HTTPClient.METHOD_POST, "/", { events = _events_to_flush })

	_events_to_flush.clear()
	_lock_flushes = false

	match res.status:
		200:
			if _has_errors(res.body.errors):
				push_error("Failed to flush events:")
				push_error(res.body.errors)

	if _flush_attempted_during_lock:
		_flush_attempted_during_lock = false
		await flush()

## Clear the queue of events waiting to be flushed.
func clear_queue() -> void:
	_queue.clear()
	_events_to_flush.clear()
	_lock_flushes = false
	_flush_attempted_during_lock = false
