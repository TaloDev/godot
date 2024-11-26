class_name TaloAuthError extends Node

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
	INVALID_EMAIL
}

var _error_string = ""

func _init(error_string: String) -> void:
	_error_string = error_string

## Get the human-readable player auth error message. 
func get_string() -> String:
	if _error_string == "API_ERROR":
		return "API error - see the Errors Output for more details"

	return _error_string

## Get the player auth error code using the ErrorCode enum.
func get_code() -> ErrorCode:
	return ErrorCode.get(_error_string)
