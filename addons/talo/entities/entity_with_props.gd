class_name TaloEntityWithProps extends RefCounted

var props: Array[TaloProp] = []

func _init(props: Array) -> void:
	self.props.assign(props)

## Get a property value by key. Returns the fallback value if the key is not found.
func get_prop(key: String, fallback: String = "") -> String:
	var filtered := props.filter(func (prop: TaloProp): return prop.key == key && prop.value != null)
	return fallback if filtered.is_empty() else filtered.front().value

## Set a property by key and value.
func set_prop(key: String, value: String) -> void:
	var filtered := props.filter(func (prop: TaloProp): return prop.key == key)
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

func _to_array_key(key: String) -> String:
	return key if key.ends_with("[]") else key + "[]"

## Get all values for a prop array by key.
func get_prop_array(key: String) -> Array[String]:
	var array_key := _to_array_key(key)
	var result: Array[String] = []

	result.assign(props.filter(func (prop: TaloProp): return prop.key == array_key && prop.value != null).map(func (prop: TaloProp): return prop.value))
	return result

## Set all values for a prop array by key, replacing any existing values.
func set_prop_array(key: String, values: Array[String]) -> void:
	var unique_values: Array[String] = []

	for v in values:
		if v != "" && !unique_values.has(v):
			unique_values.push_back(v)

	if unique_values.is_empty():
		push_error("set_prop_array: values must not be empty")
		return

	var array_key := _to_array_key(key)

	props.assign(props.filter(func (prop: TaloProp): return prop.key != array_key))
	for v in unique_values:
		props.push_back(TaloProp.new(array_key, v))

## Delete a prop array by key, leaving a sentinel null entry.
func delete_prop_array(key: String) -> void:
	var array_key := _to_array_key(key)

	var matches := props.filter(func (prop: TaloProp): return prop.key == array_key)
	if matches.is_empty():
		push_error("delete_prop_array: array key not found")
		return

	props.assign(props.filter(func (prop: TaloProp): return prop.key != array_key))
	props.push_back(TaloProp.new(array_key, null))

## Insert a value into a prop array by key.
func insert_into_prop_array(key: String, value: String) -> void:
	if value == "":
		push_error("insert_into_prop_array: value must not be empty")
		return

	var array_key := _to_array_key(key)
	var already_exists := props.any(func (prop: TaloProp): return prop.key == array_key && prop.value == value)
	if !already_exists:
		props.assign(props.filter(func (prop: TaloProp): return !(prop.key == array_key && prop.value == null)))
		props.push_back(TaloProp.new(array_key, value))

## Remove a value from a prop array by key.
func remove_from_prop_array(key: String, value: String) -> void:
	var array_key := _to_array_key(key)
	props.assign(props.filter(func (prop: TaloProp): return !(prop.key == array_key && prop.value == null)))

	var value_exists := props.any(func (prop: TaloProp): return prop.key == array_key && prop.value == value)
	if !value_exists:
		props.push_back(TaloProp.new(array_key, null))
		push_error("remove_from_prop_array: value not found in array")
		return

	props.assign(props.filter(func (prop: TaloProp): return !(prop.key == array_key && prop.value == value)))
	if !props.any(func (prop: TaloProp): return prop.key == array_key):
		props.push_back(TaloProp.new(array_key, null))
