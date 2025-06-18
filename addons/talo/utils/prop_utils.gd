class_name TaloPropUtils extends RefCounted

static func dictionary_to_array(props: Dictionary[String, Variant]) -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	var mapped_props := props.keys().map(
		func (key: String):
			return {
				key = key,
				# keep null values as-is to indicate that the prop should be deleted
				value = null if props[key] == null else str(props[key])
			}
	)
	ret.assign(mapped_props)
	return ret

static func dictionary_to_prop_array(props: Dictionary[String, String]) -> Array[TaloProp]:
	var ret: Array[TaloProp] = []
	var mapped_props := props.keys().map(
		func (key: String):
			return TaloProp.new(key, props[key])
	)
	ret.assign(mapped_props)
	return ret

static func serialise_prop_array(props: Array[TaloProp]) -> Array[Dictionary]:
	var ret: Array[Dictionary] = []
	var mapped_props = props.map(func (prop: TaloProp): return prop.to_dictionary())
	ret.assign(mapped_props)
	return ret
