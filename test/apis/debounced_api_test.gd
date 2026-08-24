extends GdUnitTestSuite

class TestHarness extends TaloDebouncedAPI:
	signal operation_started(count: int)
	signal release_operation

	var operation_result: Variant
	var operation_count: int

	func _init() -> void:
		super._init("/v1/test")

	func _run_debounced_update() -> Variant:
		operation_count += 1
		operation_started.emit(operation_count)
		await release_operation
		return operation_result

	func _build_update_result(success: bool, _operation_data: Variant) -> Variant:
		return TestResult.new(success)

	func queue_update() -> TaloDebouncedAPI.UpdateWaiter:
		return _queue_update()

	func release() -> void:
		release_operation.emit()

	class TestResult:
		var success: bool

		func _init(result_success: bool) -> void:
			success = result_success

func before_test() -> void:
	Talo.settings.debounce_timer_seconds = 0.01

func after_test() -> void:
	Talo.settings.debounce_timer_seconds = 1.0

func _make_harness(result: Variant) -> TestHarness:
	var harness: TestHarness = auto_free(TestHarness.new())
	harness.operation_result = result
	add_child(harness)
	monitor_signals(harness)
	return harness

func _release_after(harness: TestHarness, seconds: float) -> void:
	get_tree().create_timer(seconds).timeout.connect(harness.release, CONNECT_ONE_SHOT)

func test_debounced_updates_merge_into_one() -> void:
	var harness := _make_harness(TaloFixtures.make_player())
	var first := harness.queue_update()
	var second := harness.queue_update()
	var third := harness.queue_update()

	@warning_ignore("redundant_await")
	await assert_signal(harness).is_emitted(harness.operation_started, 1)
	_release_after(harness, 0.05)
	var result := await harness.flush_updates()

	assert_int(harness.operation_count).is_equal(1)
	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.SUCCESS)
	assert_bool(first.result.success).is_true()
	assert_bool(second.result.success).is_true()
	assert_bool(third.result.success).is_true()

func test_flush_forces_pending_update_and_resolves_waiter() -> void:
	var harness := _make_harness(TaloFixtures.make_player())
	harness._update_timer.wait_time = 60.0
	var waiter := harness.queue_update()
	_release_after(harness, 0.05)

	var result := await harness.flush_updates()

	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.SUCCESS)
	assert_int(harness.operation_count).is_equal(1)
	assert_bool(waiter.result.success).is_true()

func test_flush_waits_for_in_flight_update() -> void:
	var harness := _make_harness(TaloFixtures.make_player())
	var waiter := harness.queue_update()
	harness._update_timer.stop()
	harness._on_debounce_fired()
	@warning_ignore("redundant_await")
	await assert_signal(harness).is_emitted(harness.operation_started, 1)
	_release_after(harness, 0.05)

	var result := await harness.flush_updates()

	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.SUCCESS)
	assert_int(harness.operation_count).is_equal(1)
	assert_bool(waiter.result.success).is_true()

func test_queued_update_gets_its_own_result_after_in_flight_update() -> void:
	var harness := _make_harness(TaloFixtures.make_player())
	var first := harness.queue_update()
	harness._update_timer.stop()
	harness._on_debounce_fired()
	@warning_ignore("redundant_await")
	await assert_signal(harness).is_emitted(harness.operation_started, 1)

	var second := harness.queue_update()
	_release_after(harness, 0.05)
	_release_after(harness, 0.10)

	var result := await harness.flush_updates()

	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.SUCCESS)
	assert_int(harness.operation_count).is_equal(2)
	assert_bool(first.result.success).is_true()
	assert_bool(second.result.success).is_true()
	assert_bool(harness._is_queued).is_false()
	assert_bool(harness._is_executing).is_false()

func test_failed_update_resolves_waiter_and_returns_failure() -> void:
	var harness := _make_harness(null)
	harness._update_timer.wait_time = 60.0
	var waiter := harness.queue_update()
	_release_after(harness, 0.05)

	var result := await harness.flush_updates()

	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.FAILURE)
	assert_bool(waiter.result.success).is_false()

func test_flush_returns_nothing_pending_when_nothing_queued() -> void:
	var harness := _make_harness(TaloFixtures.make_player())
	var result := await harness.flush_updates()
	assert_int(result).is_equal(TaloDebouncedAPI.FlushResult.NOTHING_PENDING)
