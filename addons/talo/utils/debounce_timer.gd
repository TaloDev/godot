class_name TaloDebounceTimer extends Timer
## A one-shot timer with the wait_time equal to the debounce_timer_seconds setting. The debounce() function will throttle callback invocations.

func _init(callback: Callable) -> void:
	one_shot = true
	ignore_time_scale = true
	wait_time = Talo.settings.debounce_timer_seconds
	timeout.connect(callback)

## Start the timer using the debounce_timer_seconds setting. Subsequent calls reset the timer. On timeout, the provided callback will be invoked.
func debounce() -> void:
	start()
