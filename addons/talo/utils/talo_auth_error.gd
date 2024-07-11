class_name TaloAuthError extends Node

enum ErrorCode {
  API_ERROR,
  INVALID_CREDENTIALS,
  VERIFICATION_ALIAS_NOT_FOUND,
  VERIFICATION_CODE_INVALID,
  IDENTIFIER_TAKEN,
  MISSING_SESSION,
  INVALID_SESSION,
  NEW_PASSWORD_MATCHES_OLD_PASSWORD,
  NEW_EMAIL_MATCHES_OLD_EMAIL,
  PASSWORD_RESET_CODE_INVALID
}

# var error_map: Dictionary = {
#   "API_ERROR": ErrorCode.API_ERROR,
#   "INVALID_CREDENTIALS": ErrorCode.INVALID_CREDENTIALS,
#   "VERIFICATION_ALIAS_NOT_FOUND": ErrorCode.VERIFICATION_ALIAS_NOT_FOUND,
#   "VERIFICATION_CODE_INVALID": ErrorCode.VERIFICATION_CODE_INVALID,
#   "IDENTIFIER_TAKEN": ErrorCode.IDENTIFIER_TAKEN,
#   "MISSING_SESSION": ErrorCode.MISSING_SESSION,
#   "INVALID_SESSION": ErrorCode.INVALID_SESSION,
#   "NEW_PASSWORD_MATCHES_OLD_PASSWORD": ErrorCode.NEW_PASSWORD_MATCHES_OLD_PASSWORD,
#   "NEW_EMAIL_MATCHES_OLD_EMAIL": ErrorCode.NEW_EMAIL_MATCHES_OLD_EMAIL,
#   "PASSWORD_RESET_CODE_INVALID": ErrorCode.PASSWORD_RESET_CODE_INVALID
# }

var _error_string = ""

func _init(error_string: String) -> void:
  _error_string = error_string

func get_string() -> String:
  if _error_string == "API_ERROR":
    return "API error - see the Errors Output for more details"

  return _error_string

func get_code() -> ErrorCode:
  return ErrorCode.get(_error_string)
