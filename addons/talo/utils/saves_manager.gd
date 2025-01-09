class_name TaloSavesManager extends Node

var all_saves: Array[TaloGameSave] = []
var current_save: TaloGameSave

var _registered_saved_objects: Array[TaloSavedObject]
var _loaded_loadables: Array[String]

const _offline_saves_path = "user://ts.bin"

func read_offline_saves() -> Array[TaloGameSave]:
	if not FileAccess.file_exists(_offline_saves_path):
		return []

	var content = FileAccess.open_encrypted_with_pass(_offline_saves_path, FileAccess.READ, Talo.crypto_manager.get_key())
	if content == null:
		TaloCryptoManager.handle_undecryptable_file(_offline_saves_path, "offline saves file")
		return []

	var json = JSON.new()
	json.parse(content.get_as_text())

	var res: Array[TaloGameSave] = []
	res.assign(json.get_data().map(func (data: Dictionary): return TaloGameSave.new(data)))

	return res

func write_offline_saves(offline_saves: Array[TaloGameSave]):
	var saves = FileAccess.open_encrypted_with_pass(_offline_saves_path, FileAccess.WRITE, Talo.crypto_manager.get_key())
	saves.store_line(JSON.stringify(offline_saves.map(func (save: TaloGameSave): return save.to_dictionary())))

func sync_save(online_save: TaloGameSave, offline_save: TaloGameSave) -> TaloGameSave:
	var online_updated_at = Time.get_unix_time_from_datetime_string(online_save.updated_at)
	var offline_updated_at = Time.get_unix_time_from_datetime_string(offline_save.updated_at)

	if offline_updated_at > online_updated_at:
		var save = await Talo.saves.replace_save_with_offline_save(offline_save)
		delete_offline_save(offline_save)
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

func get_synced_saves(online_saves: Array[TaloGameSave]) -> Array[TaloGameSave]:
	var saves: Array[TaloGameSave] = []
	var offline_saves: Array[TaloGameSave] = read_offline_saves()
				
	if not offline_saves.is_empty():
		for online_save in online_saves:
			var filtered = offline_saves.filter(func (save: TaloGameSave): return save.id == online_save.id)
			if not filtered.is_empty():
				var save = await sync_save(online_save, filtered.front())
				saves.push_back(save)
			else:
				saves.push_back(online_save)
		
		var synced_saves = await sync_offline_saves(offline_saves)
		saves.append_array(synced_saves)
	
	return saves

func update_offline_saves(incoming_save: TaloGameSave) -> void:
	var offline_saves: Array[TaloGameSave] = read_offline_saves()
	var updated = false

	for i in range(offline_saves.size()):
		if offline_saves[i].id == incoming_save.id:
			offline_saves[i] = incoming_save
			updated = true
			break

	if not updated:
		if incoming_save.id == 0:
			incoming_save.id = -offline_saves.size() - 1

		offline_saves.append(incoming_save)

	write_offline_saves(offline_saves)

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
	if _loaded_loadables.size() == _registered_saved_objects.size():
		Talo.saves.save_loading_completed.emit()

func get_save_content() -> Dictionary:
	return {
		objects = _registered_saved_objects.map(func (saved_object: TaloSavedObject): return saved_object.to_dictionary())
	}

func replace_save(new_save: TaloGameSave) -> void:
	var existing_saves = all_saves.filter(func (save): return save.id == new_save.id)
	if existing_saves.is_empty():
		push_error("Save %s cannot be replaced as it does not exist" % new_save.id)
		all_saves.push_back(new_save)
	else:
		all_saves[all_saves.find(existing_saves.front())] = new_save

	if current_save.id == new_save.id:
		current_save = new_save

	update_offline_saves(new_save)

func get_latest_save() -> TaloGameSave:
	var dupe = all_saves.duplicate()
	if dupe.is_empty():
		return null

	dupe.sort_custom(
		func (a, b):
			var time_a = Time.get_unix_time_from_datetime_string(a.updated_at)
			var time_b = Time.get_unix_time_from_datetime_string(b.updated_at)
			return time_a > time_b
	)

	return dupe.front()
