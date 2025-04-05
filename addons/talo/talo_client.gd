class_name TaloClient extends Node

var _base_url: String

func _init(base_url: String):
	_base_url = base_url
	name = "Client"

func _get_method_name(method: HTTPClient.Method):
	match method:
		HTTPClient.METHOD_GET: return "GET"
		HTTPClient.METHOD_POST: return "POST"
		HTTPClient.METHOD_PUT: return "PUT"
		HTTPClient.METHOD_PATCH: return "PATCH"
		HTTPClient.METHOD_DELETE: return "DELETE"

func _simulate_offline_request() -> TaloClientResponse:
	return TaloClientResponse.new(
		HTTPRequest.RESULT_CANT_CONNECT,
		0,
		PackedStringArray(),
		PackedByteArray()
	)

func _build_response(http_request: HTTPRequest) -> TaloClientResponse:
	var res = await http_request.request_completed
	return TaloClientResponse.new(res[0], res[1], res[2], res[3])

func make_request(method: HTTPClient.Method, url: String, body: Dictionary = {}, headers: Array[String] = [], continuity: bool = false) -> Dictionary:
	var continuity_timestamp := TaloTimeUtils.get_timestamp_msec()

	var full_url := url if continuity else _build_full_url(url)
	var all_headers := headers if continuity else _build_headers(headers)
	var request_body := "" if body.keys().is_empty() else JSON.stringify(body)

	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.name = "%s %s" % [_get_method_name(method), url]

	http_request.request(full_url, all_headers, method, request_body)
	var res := _simulate_offline_request() if Talo.offline_mode_enabled() else await _build_response(http_request)
	var status := res.response_code

	var response_body := res.body
	var json := JSON.new()
	json.parse(response_body.get_string_from_utf8())

	if res.result != HTTPRequest.RESULT_SUCCESS:
		json.set_data({
			message =
				"Request failed: result %s, details: https://docs.godotengine.org/en/stable/classes/class_httprequest.html#enum-httprequest-result" % res.result
		})

	if Talo.settings.get_value("logging", "requests", false):
		print_rich("[color=%s]--> %s %s %s %s[/color]" % [
			"yellow" if continuity else "orange",
			"[CONTINUITY]" if continuity else "",
			_get_method_name(method),
			full_url,
			request_body
		])
	
	if Talo.settings.get_value("logging", "responses", false):
		print_rich("[color=green]<-- %s %s[/color]" % [status, json.data])

	var ret = {
		status = status,
		body = json.data
	}

	if ret.status >= 400:
		handle_error(ret)

	if res.result != HTTPRequest.RESULT_SUCCESS or ret.status >= 500:
		Talo.continuity_manager.push_request(method, full_url, body, all_headers, continuity_timestamp)

	http_request.queue_free()

	return ret
	
func _build_headers(extra_headers: Array[String] = []) -> Array[String]:
	var headers: Array[String] = [
		"Authorization: Bearer %s" % Talo.settings.get_value("", "access_key"),
		"Content-Type: application/json",
		"Accept: application/json",
		"X-Talo-Dev-Build: %s" % ("1" if OS.is_debug_build() else "0"),
		"X-Talo-Include-Dev-Data: %s" % ("1" if OS.is_debug_build() else "0")
	]
	
	if Talo.current_alias:
		headers.append_array([
			"X-Talo-Player: %s" % Talo.current_player.id,
			"X-Talo-Alias: %s" % Talo.current_alias.id
		])

	var session_token := Talo.player_auth.session_manager.get_token()
	if session_token:
		headers.append("X-Talo-Session: %s" % session_token)

	headers.append_array(extra_headers)
		
	return headers

func _build_full_url(url: String) -> String:
	return "%s%s%s" % [
		Talo.settings.get_value("", "api_url"),
		_base_url,
		url
	]

func handle_error(res: Dictionary) -> void:
	if res.body != null:
		if res.body.has("message"):
			push_error("%s: %s" % [res.status, res.body.message])
			return
		
		if res.body.has("errors"):
			push_error("%s: %s" % [res.status, res.body.errors])
			return

	push_error("%s: Unknown error" % res.status)

class TaloClientResponse:
	var result: int
	var response_code: int
	var headers: PackedStringArray
	var body: PackedByteArray

	func _init(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
		self.result = result
		self.response_code = response_code
		self.headers = headers
		self.body = body
