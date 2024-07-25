class_name PlayerAuthAPI extends TaloAPI

var session_manager = TaloSessionManager.new()
var last_error: Variant = null

func _handle_error(res: Dictionary, ret: Variant = FAILED) -> Variant:
	if res.body.has("errorCode"):
		last_error = TaloAuthError.new(res.body.errorCode)
	else:
		last_error = TaloAuthError.new("API_ERROR")

	return ret

func register(identifier: String, password: String, email: String = "", verification_enabled: bool = false) -> Error:
	if verification_enabled and email.is_empty():
		push_error("Email is required when verification is enabled")
		return FAILED

	var res = await client.make_request(HTTPClient.METHOD_POST, "/register", {
		identifier = identifier,
		password = password,
		email = email,
		verificationEnabled = verification_enabled
	})

	match (res.status):
		200:
			session_manager.handle_session_created(res.body.alias, res.body.sessionToken)
			return OK
		_:
			return _handle_error(res)

func login(identifier: String, password: String) -> Array[Variant]: ## [Error, bool]
	var res = await client.make_request(HTTPClient.METHOD_POST, "/login", {
		identifier = identifier,
		password = password
	})

	match (res.status):
		200:
			if res.body.has("verificationRequired"):
				session_manager.save_verification_alias_id(res.body.aliasId)
			else:
				session_manager.handle_session_created(res.body.alias, res.body.sessionToken)

			return [OK, res.body.has("verificationRequired")]
		_:
			return _handle_error(res, [FAILED, false])

func verify(verification_code: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/verify", {
		aliasId = session_manager.get_verification_alias_id(),
		code = verification_code
	})

	match (res.status):
		200:
			session_manager.handle_session_created(res.body.alias, res.body.sessionToken)
			return OK
		_:
			return _handle_error(res)

func logout() -> void:
	await client.make_request(HTTPClient.METHOD_POST, "/logout")
	session_manager.clear_session()
	Talo.current_alias = null

func change_password(current_password: String, new_password: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/change_password", {
		currentPassword = current_password,
		newPassword = new_password
	})

	match (res.status):
		204:
			return OK
		_:
			return _handle_error(res)

func change_email(current_password: String, new_email: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/change_email", {
		currentPassword = current_password,
		newEmail = new_email
	})

	match (res.status):
		204:
			return OK
		_:
			return _handle_error(res)

func forgot_password(email: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/forgot_password", {
		email = email
	})

	match (res.status):
		204:
			return OK
		_:
			return FAILED

func reset_password(code: String, password: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/reset_password", {
		code = code,
		password = password
	})

	match (res.status):
		204:
			return OK
		_:
			return _handle_error(res)
