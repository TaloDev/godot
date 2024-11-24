class_name TaloSavedObject extends Node

var id: String
var object_name: String
var loadable: TaloLoadable

func _init(loadable: TaloLoadable) -> void:
	id = loadable.id
	object_name = loadable.get_path()
	self.loadable = loadable

## Register the fields that should be saved and loaded for this object.
func register_loadable_fields():
	if is_instance_valid(loadable):
		loadable.clear_saved_fields()
		loadable.register_fields()

func to_dictionary() -> Dictionary:
	register_loadable_fields()

	var destroyed_data = [{ key = "meta.destroyed", value = str(true), type = str(TYPE_BOOL) }]

	return {
		id = id,
		name = object_name,
		data = destroyed_data if not is_instance_valid(loadable) else loadable.get_saved_object_data() 
	}
