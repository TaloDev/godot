class_name TaloDebouncedAPI extends TaloAPI

enum FlushResult {
	NOTHING_PENDING,
	SUCCESS,
	FAILURE,
}

signal _update_settled(success: bool, operation_data: Variant)

var _update_timer: TaloDebounceTimer
var _is_executing: bool
var _is_queued: bool
var _pending_waiters: Array[UpdateWaiter] = []

func _init(base_path: String) -> void:
	super(base_path)
	_update_timer = TaloDebounceTimer.new(_on_debounce_fired)
	add_child(_update_timer)

func _debounce() -> void:
	_update_timer.debounce()

func _queue_update() -> UpdateWaiter:
	var waiter := UpdateWaiter.new()
	_pending_waiters.append(waiter)
	_debounce()
	return waiter

func _run_debounced_update() -> Variant:
	return null

func _build_update_result(success: bool, operation_data: Variant) -> Variant:
	return operation_data

func _on_debounce_fired() -> void:
	# if an update is executing, queue a new update
	if _is_executing:
		_is_queued = true
		return
	# else, just execute it
	_execute_update()

func _execute_update() -> void:
	while true:
		var waiters := _pending_waiters
		_pending_waiters = []
		_is_executing = true
		var result := await _run_debounced_update()
		_is_executing = false

		var success := result != null
		if not success:
			push_error("%s debounced update failed" % name)

		# check if another update was queued during execution
		if _is_queued:
			_is_queued = false
			_is_executing = true

		var update_result := _build_update_result(success, result)
		for waiter in waiters:
			waiter.settle(update_result)
		_update_settled.emit(success, result)

		if not _is_executing:
			return

func flush_updates() -> FlushResult:
	var result := FlushResult.NOTHING_PENDING
	while _is_executing or not _update_timer.is_stopped():
		if _is_executing:
			var settled: Array = await _update_settled
			var success: bool = settled[0]
			if success:
				# don't override the failure result
				if result == FlushResult.NOTHING_PENDING:
					result = FlushResult.SUCCESS
			else:
				result = FlushResult.FAILURE
		else:
			_update_timer.stop()
			_execute_update()

	return result

class UpdateWaiter:
	signal settled(result: Variant)

	var result: Variant

	func settle(update_result: Variant) -> void:
		result = update_result
		settled.emit(update_result)
