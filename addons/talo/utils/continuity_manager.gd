class_name TaloContinuityManager extends Timer

var _client: TaloClient
var _requests: Array = []

const _CONTINUITY_PATH = "user://tc.bin"
const _CONTINUITY_TIMESTAMP_HEADER = "X-Talo-Continuity-Timestamp"

const _EXCLUDED_ENDPOINTS: Array[String] = [
	"/v1/health-check",
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
	if not Talo.settings.get_value("continuity", "enabled", true):
		return

	if _EXCLUDED_ENDPOINTS.any(func (endpoint: String): return url.find(endpoint) != -1):
		return

	_requests.push_back({
		method = method,
		url = url,
		body = body,
		headers = headers.filter(func (h: String): return h.find("Authorization") == -1),
		timestamp = timestamp
	})

	_write_requests()

func _read_requests() -> Array:
	if not FileAccess.file_exists(_CONTINUITY_PATH):
		return []

	var content := FileAccess.open_encrypted_with_pass(_CONTINUITY_PATH, FileAccess.READ, Talo.crypto_manager.get_key())
	if content == null:
		TaloCryptoManager.handle_undecryptable_file(_CONTINUITY_PATH, "continuity file")
		return []

	var json := JSON.new()
	json.parse(content.get_as_text())

	return json.get_data()

func _write_requests():
	var file := FileAccess.open_encrypted_with_pass(_CONTINUITY_PATH, FileAccess.WRITE, Talo.crypto_manager.get_key())
	file.store_line(JSON.stringify(_requests))

func _on_timeout():
	if _requests.is_empty() || not (await Talo.health_check.ping()):
		return

	for i in range(10):
		if _requests.is_empty():
			break

		var req := _requests.pop_front()
		_write_requests()

		var headers: Array[String] = ["Authorization: Bearer %s" % Talo.settings.get_value("", "access_key")]
		headers.append_array(req.headers)

		if not req.headers.any(func (h: String): return h.find(_CONTINUITY_TIMESTAMP_HEADER) != -1):
			headers.append("%s: %s" % [_CONTINUITY_TIMESTAMP_HEADER, req.timestamp])

		await _client.make_request(req.method, req.url, req.body, headers, true)
