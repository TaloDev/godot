class_name TaloRejectedProp extends RefCounted

enum RejectionReason {
	UNKNOWN_ERROR,
	PROP_KEY_TOO_LONG,
	PROP_VALUE_TOO_LONG,
	PROP_ARRAY_TOO_LONG,
	PROP_CONTAINS_PROFANITY,
	PROP_KEY_RESERVED
}

var key: String
var error: RejectionReason
var message: String

func _init(data: Dictionary) -> void:
	key = data.key
	error = RejectionReason.get(data.error, RejectionReason.UNKNOWN_ERROR)
	message = data.message

static func from_response(body: Dictionary) -> Array[TaloRejectedProp]:
	if not body.has("rejectedProps") or body.rejectedProps.size() == 0:
		return []

	var rejected_props: Array[TaloRejectedProp] = []
	rejected_props.assign(body.rejectedProps.map(func (prop: Dictionary): return TaloRejectedProp.new(prop)))
	return rejected_props
