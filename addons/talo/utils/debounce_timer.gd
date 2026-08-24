class_name TaloDebounceTimer extends Timer
## A one-shot timer with the wait_time equal to the debounce_timer_seconds setting. The debounce() function will throttle callback invocations.

var _callback: Callable

func _init(callback: Callable) -> void:
	one_shot = true
	ignore_time_scale = true
	wait_time = Talo.settings.debounce_timer_seconds

	_callback = callback
	timeout.connect(_on_timeout)

func _on_timeout() -> void:
	_callback.call()

## Fire on timeout for every debounce window that had at least one call.
func debounce() -> void:
	start()
