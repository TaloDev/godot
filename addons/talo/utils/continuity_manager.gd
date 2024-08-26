class_name TaloContinuityManager extends Timer

var _client: TaloClient
var _requests: Array = []

const _continuity_path = "user://talo_continuity.bin"
const _continuity_timestamp_header = "X-Talo-Continuity-Timestamp"

const _excluded_endpoints: Array[String] = [
  "/v1/health-check",
  "/v1/players/auth",
  "/v1/players/identify"
]

func _ready() -> void:
  _client = TaloClient.new("")
  add_child(_client)

  _requests = _read_requests()

  wait_time = 10
  connect("timeout", _on_timeout)
  start()

func _filter_headers(headers: Array[String]) -> Array[String]:
  return headers.filter(
    func (h: String):
      return h.find(_continuity_timestamp_header) == -1 && h.find("Authorization") == -1)

func push_request(method: HTTPClient.Method, url: String, body: Dictionary, headers: Array[String], timestamp: int):
  if not Talo.config.get_value("continuity", "enabled", true):
    return

  if _excluded_endpoints.any(func (endpoint: String): return url.find(endpoint) != -1):
    return

  _requests.push_back({
    method = method,
    url = url,
    body = body,
    headers = _filter_headers(headers),
    timestamp = timestamp
  })

  print(_filter_headers(headers))

  _write_requests()

func _read_requests() -> Array:
  if not FileAccess.file_exists(_continuity_path):
    return []

  var content = FileAccess.open_encrypted_with_pass(_continuity_path, FileAccess.READ, Talo.crypto_manager.get_key())
  var json = JSON.new()
  json.parse(content.get_as_text())

  return json.get_data()

func _write_requests():
  var file = FileAccess.open_encrypted_with_pass(_continuity_path, FileAccess.WRITE, Talo.crypto_manager.get_key())
  file.store_line(JSON.stringify(_requests))

func _on_timeout():
  if _requests.is_empty() || not (await Talo.health_check.ping()):
    return

  for i in range(10):
    if _requests.is_empty():
      break

    var req = _requests.pop_front()
    _write_requests()

    var headers: Array[String] = [
      "%s: %s" % [_continuity_timestamp_header, req.timestamp],
      "Authorization: Bearer %s" % Talo.config.get_value("", "access_key")
    ]
    headers.append_array(req.headers)

    await _client.make_request(req.method, req.url, req.body, headers, true)