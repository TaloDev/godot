class_name TaloClient extends HTTPRequest

var _base_url: String

func _init(base_url: String):
	_base_url = base_url

func _get_method_name(method: HTTPClient.Method):
	match method:
		HTTPClient.METHOD_GET: return "GET"
		HTTPClient.METHOD_POST: return "POST"
		HTTPClient.METHOD_PUT: return "PUT"
		HTTPClient.METHOD_PATCH: return "PATCH"
		HTTPClient.METHOD_DELETE: return "DELETE"

func make_request(method: HTTPClient.Method, url: String, body: Dictionary = {}) -> Dictionary:	
	var full_url = _build_full_url(url)
	var request_body = "" if body.keys().is_empty() else JSON.stringify(body)
	request(full_url, _build_headers(), method, request_body)

	var res = await request_completed
	var status = res[1]

	var response_body = res[3]
	var json = JSON.new()
	json.parse(response_body.get_string_from_utf8())

	if res[0] != RESULT_SUCCESS:
		json.set_data({
			message =
				"Request failed with Result %s, visit the Godot docs for more details: https://docs.godotengine.org/en/stable/classes/class_httprequest.html#enum-httprequest-result" % res[0]
		})

	if Talo.config.get_value("logging", "requests"):
		print_rich("[color=orange]--> %s %s %s[/color]" % [_get_method_name(method), full_url, request_body])
	
	if Talo.config.get_value("logging", "responses"):
		print_rich("[color=green]<-- %s %s[/color]" % [status, json.get_data()])

	var ret = {
		status = status,
		body = json.get_data()
	}

	if ret.status >= 400:
		handle_error(ret)

	return ret
	
func _build_headers() -> Array:
	var headers = [
		"Authorization: Bearer %s" % Talo.config.get_value("", "access_key"),
		"Content-Type: application/json",
		"Accept: application/json",
		"X-Talo-Dev-Build: %s" % ("1" if OS.has_feature("debug") else "0"),
		"X-Talo-Include-Dev-Data: %s" % ("1" if OS.has_feature("debug") else "0")
	]
	
	if Talo.current_alias:
		headers.append_array([
			'X-Talo-Player: %s' % Talo.current_player.id,
			'X-Talo-Alias: %s' % Talo.current_alias.id
		])

	var session_token = Talo.player_auth.session_manager.load_session()
	if session_token:
		headers.append('X-Talo-Session: %s' % session_token)
		
	return headers

func _build_full_url(url: String) -> String:
	return "%s%s%s" % [
		Talo.config.get_value("", "api_url"),
		_base_url,
		url
	]

func handle_error(res: Dictionary) -> void:
	if res.body.has("message"):
		push_error("%s: %s" % [res.status, res.body.message])
		return
	
	if res.body.has("errors"):
		push_error("%s: %s" % [res.status, res.body.errors])
		return

	push_error("%s: Unknown error" % res.status)

