class_name TaloPropUtils extends RefCounted

static func serialise_dictionary(props: Dictionary[String, Variant]) -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	for key in props.keys():
		var val := props.get(key)
		if key.ends_with("[]") and val is Array:
			if val.is_empty():
				ret.push_back({ key = key, value = null })
			else:
				for v in val:
					ret.push_back({ key = key, value = str(v) })
		else:
			# keep null values as-is to indicate that the prop should be deleted
			ret.push_back({ key = key, value = null if val == null else str(val) })
	return ret

static func dictionary_to_props(props: Dictionary[String, Variant]) -> Array[TaloProp]:
	var ret: Array[TaloProp] = []
	for key in props.keys():
		var val := props.get(key)
		if key.ends_with("[]") and val is Array:
			for v in val:
				ret.push_back(TaloProp.new(key, str(v)))
		else:
			ret.push_back(TaloProp.new(key, val))
	return ret

static func props_to_dictionary(props: Array[TaloProp]) -> Dictionary[String, Variant]:
	var ret: Dictionary[String, Variant] = {}
	for prop in props:
		if prop.key.ends_with("[]"):
			if !ret.has(prop.key):
				ret[prop.key] = []
			if prop.value != null:
				ret[prop.key].push_back(prop.value)
		else:
			ret[prop.key] = prop.value
	return ret

static func serialise_props(props: Array[TaloProp]) -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	var mapped_props = props.map(func (prop: TaloProp): return prop.to_dictionary())
	ret.assign(mapped_props)
	return ret
