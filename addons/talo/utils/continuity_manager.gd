class_name TaloContinuityManager extends Timer

var _client: TaloClient
var _requests: Array = []

const _CONTINUITY_PATH = "user://tc.bin"
const _CONTINUITY_TIMESTAMP_HEADER = "X-Talo-Continuity-Timestamp"

const _HEALTH_CHECK_ENDPOINT := "/v1/health-check"
const _EXCLUDED_ENDPOINTS: Array[String] = [
	_HEALTH_CHECK_ENDPOINT,
	"/v1/players/auth",
	"/v1/players/identify",
	"/v1/socket-tickets"
]

func _ready() -> void:
	name = "TaloContinuityManager"
	_client = TaloClient.new("")
	add_child(_client)

	_requests = _read_requests()

	wait_time = 10
	connect("timeout", _on_timeout)
	start()

func push_request(method: HTTPClient.Method, url: String, body: Dictionary, headers: Array[String], timestamp: int):
	_requests.push_back({
		method = method,
		url = url,
		body = body.duplicate(true),
		headers = headers.filter(func (h: String): return h.find("Authorization") == -1),
		timestamp = timestamp
	})

	_write_requests()

func _read_requests() -> Array:
	if not FileAccess.file_exists(_CONTINUITY_PATH):
		return []

	var file := FileAccess.open_encrypted_with_pass(_CONTINUITY_PATH, FileAccess.READ, Talo.crypto_manager.get_key())
	if file == null:
		TaloCryptoManager.handle_undecryptable_file(_CONTINUITY_PATH, "continuity file")
		return []

	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()

	return json.data

func _write_requests():
	var file := FileAccess.open_encrypted_with_pass(_CONTINUITY_PATH, FileAccess.WRITE, Talo.crypto_manager.get_key())
	file.store_line(JSON.stringify(_requests))
	file.close()

func _on_timeout():
	if _requests.is_empty() or not (await Talo.health_check.ping()):
		return

	for i in range(10):
		if _requests.is_empty():
			break

		var req := _requests.pop_front()
		_write_requests()

		var headers: Array[String] = ["Authorization: Bearer %s" % Talo.settings.access_key]
		headers.append_array(req.headers)

		if not req.headers.any(func (h: String): return h.find(_CONTINUITY_TIMESTAMP_HEADER) != -1):
			headers.append("%s: %s" % [_CONTINUITY_TIMESTAMP_HEADER, req.timestamp])

		await _client.make_request(req.method, req.url, req.body, headers, true)

func request_can_be_replayed(method: HTTPClient.Method, url: String, res: TaloClient.TaloClientResponse) -> bool:
	if not Talo.settings.continuity_enabled:
		return false

	if _EXCLUDED_ENDPOINTS.any(func (endpoint: String): return url.find(endpoint) != -1):
		return false

	var allowed_methods := [
		HTTPClient.Method.METHOD_POST,
		HTTPClient.Method.METHOD_PUT,
		HTTPClient.Method.METHOD_PATCH,
		HTTPClient.Method.METHOD_DELETE
	]

	if not allowed_methods.has(method):
		return false

	return res.result != HTTPRequest.RESULT_SUCCESS or res.response_code > 500

func clear_requests() -> void:
	_requests.clear()
	_write_requests()

func handle_post_response_healthcheck(url: String, res: TaloClient.TaloClientResponse):
	if url.find(_HEALTH_CHECK_ENDPOINT) != -1:
		return

	var success := true if res.result == HTTPRequest.RESULT_SUCCESS else false

	if success:
		# if offline mode is enabled, check if it should be disabled
		if Talo.health_check.get_last_status() == Talo.health_check.HealthCheckStatus.FAILED:
			await Talo.health_check.ping()
	else:
		# if offline mode isn't enabled, check if it should be enabled
		if Talo.health_check.get_last_status() != Talo.health_check.HealthCheckStatus.FAILED:
			await Talo.health_check.ping()
