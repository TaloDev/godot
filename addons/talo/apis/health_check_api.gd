class_name HealthCheckAPI extends TaloAPI
## An interface for communicating with the Talo Health Check API.
##
## This API is used to check if Talo can be reached by Continuity. You shouldn't need to use this API directly in your game.
##
## @tutorial: https://docs.trytalo.com/docs/godot/continuity

enum HealthCheckStatus {
	OK,
	FAILED,
	UNKNOWN
}

var _cached_result := HealthCheckStatus.UNKNOWN
var _can_ping := true
var _timer := TaloDebounceTimer.new(func (): _can_ping = true)

func _ready() -> void:
	add_child(_timer)

## Check if the Talo API can be reached.
func ping() -> bool:
	var bust_cache := _can_ping or _cached_result == HealthCheckStatus.UNKNOWN
	if not bust_cache:
		return _cached_result == HealthCheckStatus.OK

	_can_ping = false
	_timer.debounce()

	var res := await client.make_request(HTTPClient.METHOD_GET, "")
	var success := true if res.status == 204 else false
	var failed_last_health_check := _cached_result == HealthCheckStatus.FAILED

	if success:
		_cached_result = HealthCheckStatus.OK
		if failed_last_health_check:
			Talo.connection_restored.emit()
	else:
		_cached_result = HealthCheckStatus.FAILED
		if not failed_last_health_check:
			Talo.connection_lost.emit()

	return success

## Get the latest known health check status.
func get_last_status() -> HealthCheckStatus:
	return _cached_result
