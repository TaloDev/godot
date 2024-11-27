class_name TaloEntityWithProps extends Node

var props: Array[TaloProp] = []

func _init(props: Array) -> void:
	self.props.assign(props)

## Get a property value by key. Returns the fallback value if the key is not found.
func get_prop(key: String, fallback: String = "") -> String:
	var filtered = props.filter(func (prop: TaloProp): return prop.key == key && prop.value != null)
	return fallback if filtered.is_empty() else filtered.front().value

## Set a property by key and value.
func set_prop(key: String, value: String) -> void:
	var filtered = props.filter(func (prop: TaloProp): return prop.key == key)
	if filtered.is_empty():
		props.push_back(TaloProp.new(key, value))
	else:
		filtered.front().value = value

## Delete a property by key.
func delete_prop(key: String) -> void:
	props.assign(props.map(
		func (prop: TaloProp):
			if prop.key == key:
				prop.value = null
			return prop
	))

func get_serialized_props() -> Array:
	return props.map(func (prop: TaloProp): return prop.to_dictionary())
