class_name TaloSocketError extends RefCounted

enum ErrorCode {
	API_ERROR,
	INVALID_MESSAGE,
	INVALID_MESSAGE_DATA,
	NO_PLAYER_FOUND,
	UNHANDLED_REQUEST,
	ROUTING_ERROR,
	LISTENER_ERROR,
	INVALID_SOCKET_TOKEN,
	INVALID_SESSION_TOKEN,
	MISSING_ACCESS_KEY_SCOPES,
	RATE_LIMIT_EXCEEDED
}

## The original req that triggered the error.
var req: String

## The socket error code using the ErrorCode enum.
var code: ErrorCode

## The human-readable socket error message. 
var message: String

## The cause of the error. Only some error types will provide this.
var cause: String

func _init(error_data: Dictionary) -> void:
	req = error_data.get("req", "unknown")
	code = ErrorCode.get(error_data.get("errorCode"), "API_ERROR")
	message = error_data.get("message", "")
	cause = error_data.get("cause", "")
