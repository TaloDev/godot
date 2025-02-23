class_name TaloLiveConfig extends RefCounted
## The live config is a set of key-value pairs that can be updated in the Talo dashboard.
##
## @tutorial: https://docs.trytalo.com/docs/godot/live-config

var props: Array[TaloProp] = []

func _init(p_props: Array) -> void:
	self.props.assign(p_props.map(func (prop: Dictionary) -> TaloProp: return TaloProp.new(prop.key, prop.value)))

## Get a property value by key. Returns the fallback value if the key is not found.
func get_prop(key: String, fallback: String) -> String:
	var filtered := props.filter(func (prop: TaloProp) -> bool: return prop.key == key)
	return fallback if filtered.is_empty() else filtered.front().value
