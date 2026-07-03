class_name TaloPlayerAuthError extends RefCounted

enum ErrorCode {
	API_ERROR,
	INVALID_CREDENTIALS,
	VERIFICATION_ALIAS_NOT_FOUND,
	VERIFICATION_CODE_INVALID,
	IDENTIFIER_TAKEN,
	MISSING_SESSION,
	INVALID_SESSION,
	NEW_PASSWORD_MATCHES_CURRENT_PASSWORD,
	NEW_EMAIL_MATCHES_CURRENT_EMAIL,
	PASSWORD_RESET_CODE_INVALID,
	VERIFICATION_EMAIL_REQUIRED,
	INVALID_EMAIL,
	NEW_IDENTIFIER_MATCHES_CURRENT_IDENTIFIER,
	INVALID_MIGRATION_TARGET,
	EMAIL_TAKEN,
	IDENTIFIER_PROFANITY
}

## The player auth error code, or [code]API_ERROR[/code] when missing/unknown.
var error: ErrorCode

## The human-readable message from the response, or a fallback for API errors.
var message: String

func _init(error_code: ErrorCode = ErrorCode.API_ERROR, message: String = "") -> void:
	error = error_code
	self.message = message

static func from_response(body: Variant) -> TaloPlayerAuthError:
	var code := ErrorCode.API_ERROR
	var message := "API error - see the Errors Output for more details"
	if body is Dictionary:
		if body.has("errorCode"):
			code = ErrorCode.get(body.errorCode, ErrorCode.API_ERROR)
			message = body.get("message", "Unknown error")
		elif body.has("message"):
			message = body.message

	return TaloPlayerAuthError.new(code, message)
