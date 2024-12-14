class_name PlayerAuthAPI extends TaloAPI
## An interface for communicating with the Talo Player Auth API.
##
## This API is used to handle player authentication in your game. It provides methods for registering, logging in and managing player accounts.
##
## @tutorial: https://docs.trytalo.com/docs/godot/player-authentication

var session_manager = TaloSessionManager.new()
var last_error: Variant = null

func _handle_error(res: Dictionary, ret: Variant = FAILED) -> Variant:
	if res.body != null and res.body.has("errorCode"):
		last_error = TaloAuthError.new(res.body.errorCode)
	else:
		last_error = TaloAuthError.new("API_ERROR")

	return ret

## Register a new player account. If verification is enabled, a valid email will be required to verify all logins.
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
			session_manager.handle_session_created(res.body.alias, res.body.sessionToken, res.body.socketToken)
			return OK
		_:
			return _handle_error(res)

## Log in to an existing player account. If verification is required, a verification code will be sent to the player's email.
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
				session_manager.handle_session_created(res.body.alias, res.body.sessionToken, res.body.socketToken)

			return [OK, res.body.has("verificationRequired")]
		_:
			return _handle_error(res, [FAILED, false])

## Verify a player account using the verification code sent to the player's email.
func verify(verification_code: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/verify", {
		aliasId = session_manager.get_verification_alias_id(),
		code = verification_code
	})

	match (res.status):
		200:
			session_manager.handle_session_created(res.body.alias, res.body.sessionToken, res.body.socketToken)
			return OK
		_:
			return _handle_error(res)

## Log out of the current player account.
func logout() -> void:
	await client.make_request(HTTPClient.METHOD_POST, "/logout")
	session_manager.clear_session()
	Talo.current_alias = null

## Change the password of the current player account.
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

## Change the email of the current player account.
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

## Send a password reset email to the player's email.
func forgot_password(email: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/forgot_password", {
		email = email
	})

	match (res.status):
		204:
			return OK
		_:
			return FAILED

## Reset the password of the player account using the code sent to the player's email.
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

## Toggle email verification for the current player account.
func toggle_verification(current_password: String, verification_enabled: bool, email: String = "") -> Error:
	var res = await client.make_request(HTTPClient.METHOD_PATCH, "/toggle_verification", {
		currentPassword = current_password,
		verificationEnabled = verification_enabled,
		email = email
	})

	match (res.status):
		204:
			return OK
		_:
			return _handle_error(res)

## Delete the current player account.
func delete_account(current_password: String) -> Error:
	var res = await client.make_request(HTTPClient.METHOD_DELETE, "/", {
		currentPassword = current_password
	})

	match (res.status):
		204:
			session_manager.clear_session()
			Talo.current_alias = null
			return OK
		_:
			return _handle_error(res)
