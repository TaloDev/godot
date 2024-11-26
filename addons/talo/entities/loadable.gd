class_name TaloLoadable extends Node
## An object that can be saved and loaded.
##
## This class is used to save and load objects in your game. It should be inherited by a child class that implements register_fields() and on_loaded(). The saving and loading logic is managed by the SavesAPI and SavesManager.
##
## @tutorial: https://docs.trytalo.com/docs/godot/saves

## The unique identifier for this loadable.
@export var id: String

var _saved_fields: Dictionary

func _ready() -> void:
	Talo.saves.save_chosen.connect(_load_data)
	Talo.saves.register(self)

func _load_data(save: TaloGameSave) -> void:
	if not save:
		return

	var fields = {}

	var filtered = save.content.objects.filter(func (obj: Dictionary): return obj.id == id)
	if filtered.is_empty():
		push_warning("Loadable with id '%s' not found in save '%s'" % [id, save.display_name])
		return

	var saved_object = filtered.front()

	for item in saved_object.data:
		fields[item.key] = type_convert(item.value, int(item.type))

	on_loaded(fields)

	Talo.saves.set_object_loaded(id)

## Clear all the saved data for this loadable.
func clear_saved_fields() -> void:
	_saved_fields.clear()

## Register all the fields that should be saved and loaded. This must be implemented by the child class.
func register_fields() -> void:
	assert(false, "register_fields() must be implemented")

## Register the given key with a value. When this object is saved, the value will be saved and loaded.
func register_field(key: String, value: Variant) -> void:
	_saved_fields[key] = value

## Handle the loaded data. This must be implemented by the child class.
func on_loaded(data: Dictionary) -> void:
	assert(false, "on_loaded() must be implemented")

## Handle if this object was previously destroyed. If it was, remove it from the scene.
func handle_destroyed(data: Dictionary) -> bool:
	var destroyed = data.has("meta.destroyed")
	if destroyed:
		queue_free()

	return destroyed

## Serialise the saved fields.
func get_saved_object_data() -> Array:
	return _saved_fields.keys().map(
	func (key: String):
		var value = _saved_fields[key]
		return {key = key, value = str(value), type = str(typeof(value))}
	)
