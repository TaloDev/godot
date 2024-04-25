class_name TaloSavesManager extends Node

var all_saves: Array[TaloGameSave] = []
var current_save: TaloGameSave

var _registered_saved_objects: Array[TaloSavedObject]
var _loaded_loadables: Array[String]

var _offline_saves_path = "user://saves.json"

func read_offline_saves() -> Array[TaloGameSave]:
	if not FileAccess.file_exists(_offline_saves_path):
		return []

	var saves = FileAccess.open(_offline_saves_path, FileAccess.READ)
	var json = JSON.new()
	json.parse(saves)

	return json.map(func (data: Dictionary): return TaloGameSave.new(data))

func write_offline_saves(offline_saves: Array[TaloGameSave]):
	var saves = FileAccess.open(_offline_saves_path, FileAccess.WRITE)
	saves.store_line(JSON.stringify(offline_saves))

func sync_save(online_save: TaloGameSave, offline_save: TaloGameSave) -> TaloGameSave:
	var online_updated_at = Time.get_unix_time_from_datetime_string(online_save.updated_at)
	var offline_updated_at = Time.get_unix_time_from_datetime_string(offline_save.updated_at)

	if offline_updated_at > online_updated_at:
		var save = await Talo.Saves.replace_save_with_offline_save(offline_save)
		return save

	return online_save

func delete_offline_save(save: TaloGameSave):
	var offline_saves: Array[TaloGameSave] = read_offline_saves()
	offline_saves = offline_saves.filter(func (s: TaloGameSave): return s.id != save.id)
	write_offline_saves(offline_saves)

func sync_offline_saves(offline_saves: Array[TaloGameSave]) -> Array[TaloGameSave]:
	var new_saves: Array[TaloGameSave] = []

	for offline_save in offline_saves:
		if offline_save.id < 0:
			var save = await Talo.saves.create_save(offline_save.display_name, offline_save.content)
			delete_offline_save(offline_save)
			new_saves.push_back(save)
	
	return new_saves

func update_offline_saves(incoming_save: TaloGameSave) -> void:
	pass

func register_fields_for_saved_objects():
	for saved_object in _registered_saved_objects:
		saved_object.register_loadable_fields()

func set_chosen_save(save: TaloGameSave, load_save: bool) -> void:
	current_save = save
	if not load_save:
		return

	_loaded_loadables.clear()
	Talo.saves.save_chosen.emit(save)

func register(loadable: TaloLoadable) -> void:
	_registered_saved_objects.push_back(TaloSavedObject.new(loadable))

func set_object_loaded(id: String) -> void:
	_loaded_loadables.push_back(id)

func get_save_content() -> Dictionary:
	return {
		objects = _registered_saved_objects.map(func (saved_object: TaloSavedObject): return saved_object.to_dictionary())
  }

func replace_save(new_save: TaloGameSave) -> void:
	var existing_saves = all_saves.filter(func (save): return save.id == new_save.id)
	if existing_saves.is_empty():
		push_error("Save %s cannot be replaced as it does not exist" % [new_save.id])
		all_saves.push_back(new_save)
	else:
		all_saves[all_saves.find(existing_saves.front())] = new_save

	if current_save.id == new_save.id:
		current_save = new_save

	update_offline_saves(new_save)
