class_name PlayerAuthAPI extends TaloAPI
## An interface for communicating with the Talo Player Auth API.
##
## This API is used to handle player authentication in your game. It provides methods for registering, logging in and managing player accounts.
##
## @tutorial: https://docs.trytalo.com/docs/godot/player-authentication

## Emitted when Talo.player_auth.start_session() is called and a valid session is found.
signal session_found()

## Emitted when Talo.player_auth.start_session() is called and no valid session is found.
signal session_not_found()

var session_manager := TaloSessionManager.new()
var session_refresh_request: SessionRefreshRequest = null

## Identify the player if they have a valid session.
func start_session() -> void:
	if await session_manager.check_for_session():
		session_found.emit()
		Talo.players.identify("talo", session_manager.get_identifier())
	else:
		session_not_found.emit()

## Register a new player account. If verification is enabled, a valid email will be required to verify all logins.
func register(identifier: String, password: String, email: String = "", verification_enabled: bool = false) -> PlayerAuthResult:
	if verification_enabled and email.is_empty():
		push_error("Email is required when verification is enabled")
		var error := TaloPlayerAuthError.from_response({ message = "Email is required when verification is enabled" })
		return PlayerAuthResult.new(error)

	var res := await client.make_request(HTTPClient.METHOD_POST, "/register", {
		identifier = identifier,
		password = password,
		email = email,
		verificationEnabled = verification_enabled,
		withRefresh = true
	})

	match res.status:
		200:
			session_manager.handle_session_created(
				res.body.alias,
				res.body.sessionToken,
				res.body.refreshToken,
				res.body.socketToken
			)
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Log in to an existing player account. If verification is required, a verification code will be sent to the player's email.
func login(identifier: String, password: String) -> PlayerAuthLoginResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/login", {
		identifier = identifier,
		password = password,
		withRefresh = true
	})

	match res.status:
		200:
			var verification_required: bool = res.body.get("verificationRequired", false)
			if verification_required:
				session_manager.save_verification_alias_id(res.body.aliasId)
			else:
				session_manager.handle_session_created(
					res.body.alias,
					res.body.sessionToken,
					res.body.refreshToken,
					res.body.socketToken
				)

			return PlayerAuthLoginResult.new(null, verification_required)
		_:
			return PlayerAuthLoginResult.new(TaloPlayerAuthError.from_response(res.body))

## Verify a player account using the verification code sent to the player's email.
func verify(verification_code: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/verify", {
		aliasId = session_manager.get_verification_alias_id(),
		code = verification_code,
		withRefresh = true
	})

	match res.status:
		200:
			session_manager.handle_session_created(
				res.body.alias,
				res.body.sessionToken,
				res.body.refreshToken,
				res.body.socketToken
			)
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Log out of the current player account.
func logout() -> void:
	await client.make_request(HTTPClient.METHOD_POST, "/logout")
	session_manager.clear_session()

## Refresh the current session.
func refresh() -> PlayerAuthResult:
	var refresh_token := session_manager.get_refresh_token()
	if refresh_token.is_empty():
		var error := TaloPlayerAuthError.from_response({ message = "No refresh token available" })
		return PlayerAuthResult.new()

	if session_refresh_request != null:
		return await session_refresh_request.completed

	session_refresh_request = SessionRefreshRequest.new()
	var res := await client.make_request(HTTPClient.METHOD_POST, "/refresh", {
		refreshToken = refresh_token
	})

	var result: PlayerAuthResult
	match res.status:
		200:
			session_manager.handle_session_refreshed(res.body.sessionToken, res.body.refreshToken)
			result = PlayerAuthResult.new()
		_:
			session_manager.clear_session()
			result = PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

	session_refresh_request.completed.emit(result)
	session_refresh_request = null
	return result

## Change the password of the current player account.
func change_password(current_password: String, new_password: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/change_password", {
		currentPassword = current_password,
		newPassword = new_password
	})

	match res.status:
		204:
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Change the email of the current player account.
func change_email(current_password: String, new_email: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/change_email", {
		currentPassword = current_password,
		newEmail = new_email
	})

	match res.status:
		204:
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Change the identifier of the current player alias.
func change_identifier(current_password: String, new_identifier: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/change_identifier", {
		currentPassword = current_password,
		newIdentifier = new_identifier
	})

	match res.status:
		200:
			session_manager.handle_identifier_changed(TaloPlayerAlias.new(res.body.alias))
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Send a password reset email to the player's email.
func forgot_password(email: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/forgot_password", {
		email = email
	})

	match res.status:
		204:
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Reset the password of the player account using the code sent to the player's email.
func reset_password(code: String, password: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/reset_password", {
		code = code,
		password = password
	})

	match res.status:
		204:
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Toggle email verification for the current player account.
func toggle_verification(current_password: String, verification_enabled: bool, email: String = "") -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_PATCH, "/toggle_verification", {
		currentPassword = current_password,
		verificationEnabled = verification_enabled,
		email = email
	})

	match res.status:
		204:
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Delete the current player account.
func delete_account(current_password: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_DELETE, "/", {
		currentPassword = current_password
	})

	match res.status:
		204:
			session_manager.clear_session()
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

## Migrate the current player account to a different service and identifier.
func migrate_account(current_password: String, new_service: String, new_identifier: String) -> PlayerAuthResult:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/migrate", {
		currentPassword = current_password,
		service = new_service,
		identifier = new_identifier
	})

	match res.status:
		200:
			session_manager.handle_account_migrated(TaloPlayerAlias.new(res.body.alias))
			return PlayerAuthResult.new()
		_:
			return PlayerAuthResult.new(TaloPlayerAuthError.from_response(res.body))

class PlayerAuthResult:
	var error: TaloPlayerAuthError = null

	var success: bool:
		get: return error == null

	func _init(error: TaloPlayerAuthError = null) -> void:
		self.error = error

class PlayerAuthLoginResult extends PlayerAuthResult:
	var verification_required: bool = false

	func _init(error: TaloPlayerAuthError = null, verification_required: bool = false) -> void:
		super(error)
		self.verification_required = verification_required

class SessionRefreshRequest extends RefCounted:
	signal completed(result: PlayerAuthResult)
