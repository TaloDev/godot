class_name TaloProp extends RefCounted

var key: String
## String or null
var value: Variant:
	set(v):
		value = str(v) if v != null else v

func _init(p_key: String, p_value: Variant) -> void:
	self.key = p_key
	self.value = p_value

func to_dictionary() -> Dictionary:
	return { key = key, value = value }
