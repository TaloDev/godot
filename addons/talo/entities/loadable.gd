class_name TaloLoadable extends Node
## An object that can be saved and loaded.
##
## This class is used to save and load objects in your game. It should be inherited by a child class that implements register_fields() and on_loaded(). The saving and loading logic is managed by the SavesAPI and SavesManager.
##
## @tutorial: https://docs.trytalo.com/docs/godot/saves

## The unique identifier for this loadable.
@export var id: String

var _saved_fields: Dictionary[String, Variant]

func _ready() -> void:
	Talo.saves.register(self)

func _convert_serialised_data(item: Dictionary) -> Variant:
	match Talo.saves.get_format_version():
		"godot.v1": return type_convert(item.value, int(item.type))
		_: return str_to_var(item.value)

## Update this loadable with the latest data.
func hydrate(data: Array[Dictionary]) -> void:
	var fields := {}
	for item in data:
		fields[item.key] = _convert_serialised_data(item)

	on_loaded(fields)

## Register all the fields that should be saved and loaded. This can remain unimplemented if you only care about the loadable's presence in the scene.
func register_fields() -> void:
	pass

## Register the given key with a value. When this object is saved, the value will be saved and loaded.
func register_field(key: String, value: Variant) -> void:
	_saved_fields.set(key, value)

## Handle the loaded data. This must be implemented by the child class.
func on_loaded(data: Dictionary) -> void:
	assert(false, "on_loaded() must be implemented")

## Handle if this object was previously destroyed. If it was, remove it from the scene.
func handle_destroyed(data: Dictionary) -> bool:
	var destroyed = data.has("meta.destroyed")
	if destroyed:
		queue_free()

	return destroyed

## Ensure the data is up-to-date and return the serialised saved fields.
func get_latest_data() -> Array[Dictionary]:
	register_fields()

	var data: Array[Dictionary] = []
	data.assign(_saved_fields.keys().map(
		func (key: String):
			var value = _saved_fields[key]
			return {
				key = key,
				value = var_to_str(value),
				type = str(typeof(value))
			}
	))
	return data
