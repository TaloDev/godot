class_name TaloSavedObject extends RefCounted

var loadable: TaloLoadable
var id: String
var name: String
var _cached_data: Array[Dictionary] = []

func _init(saved_object: Dictionary) -> void:
	id = saved_object.id
	name = saved_object.get("name", "unknown")
	_cached_data.assign(saved_object.data)

# Match a loadable with a saved object to hydrate the loadable with the latest data.
func register_loadable(loadable: TaloLoadable):
	self.loadable = loadable
	loadable.hydrate(_cached_data)

func _get_latest_data() -> Array[Dictionary]:
	_cached_data.assign(loadable.get_latest_data())
	return _cached_data

func _is_loadable_valid() -> bool:
	return is_instance_valid(loadable)

func _current_scene_matches_name() -> bool:
	if not _is_loadable_valid():
		return false

	var root_path := loadable.get_tree().current_scene.get_path()
	return name.begins_with(root_path)

func _serialise_data() -> Array[Dictionary]:
	if is_instance_valid(loadable) and not loadable.is_queued_for_deletion():
		return _get_latest_data()

	if not _current_scene_matches_name():
		return _cached_data

	_cached_data.push_back({ key = "meta.destroyed", value = str(true), type = str(TYPE_BOOL) })
	return _cached_data

# Serialise the saved object so that it can be saved.
func to_dictionary() -> Dictionary:
	return {
		id = id,
		name = name,
		data = _serialise_data()
	}
