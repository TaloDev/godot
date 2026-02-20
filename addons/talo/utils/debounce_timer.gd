class_name TaloDebounceTimer extends Timer
## A one-shot timer with the wait_time equal to the debounce_timer_seconds setting. The debounce() function will throttle callback invocations.

var _callback: Callable
var _has_pending: bool
var _leading: bool

func _init(callback: Callable, leading: bool = true) -> void:
	one_shot = true
	ignore_time_scale = true
	wait_time = Talo.settings.debounce_timer_seconds

	_callback = callback
	_leading = leading
	timeout.connect(_on_leading_timeout if leading else _on_timeout)

func _on_timeout() -> void:
	_callback.call()

func _on_leading_timeout() -> void:
	if _has_pending:
		_has_pending = false
		_callback.call()

## In leading mode: fire immediately on the first call, and again on timeout only if subsequent calls were made.
## In trailing mode: fire on timeout for every debounce window that had at least one call.
func debounce() -> void:
	if _leading:
		_handle_leading_debounce()
	start()

func _handle_leading_debounce() -> void:
	if is_stopped():
		_callback.call()
	else:
		_has_pending = true
