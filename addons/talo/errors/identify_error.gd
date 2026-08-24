class_name TaloIdentifyError extends RefCounted

enum ErrorCode {
	UNKNOWN_ERROR,
	IDENTIFIER_PROFANITY,
	IDENTIFIER_TAKEN
}

var code: ErrorCode

func _init(code: ErrorCode = ErrorCode.UNKNOWN_ERROR) -> void:
	self.code = code

static func from_response(body: Variant) -> TaloIdentifyError:
	var code := ErrorCode.UNKNOWN_ERROR
	if body is Dictionary and body.has("errorCode"):
		code = ErrorCode.get(body.errorCode, ErrorCode.UNKNOWN_ERROR)
	return TaloIdentifyError.new(code)
