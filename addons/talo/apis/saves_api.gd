class_name SavesAPI extends TaloAPI

signal saves_loaded
signal save_chosen(save: TaloGameSave)
signal save_loading_completed

var _saves_manager = TaloSavesManager.new()

var all:
	get: return _saves_manager.all_saves

var latest:
	get: return get_latest_save()

var current:
	get: return _saves_manager.current_save

func get_latest_save() -> TaloGameSave:
	var dupe = _saves_manager.all_saves.duplicate()
	if dupe.is_empty():
		return null

	dupe.sort_custom(
		func (a, b):
			var time_a = Time.get_unix_time_from_datetime_string(a.updated_at)
			var time_b = Time.get_unix_time_from_datetime_string(b.updated_at)
			return time_a > time_b
	)

	return dupe.front()

func replace_save_with_offline_save(offline_save: TaloGameSave) -> TaloGameSave:
	var res = await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % offline_save.id, {
		name=offline_save.display_name,
		content=offline_save.content
	})

	match (res.status):
		200:
			return TaloGameSave.new(res.body.save)
		_:
			return null

func get_saves() -> Array[TaloGameSave]:
	var saves: Array[TaloGameSave] = []
	var offline_saves: Array[TaloGameSave] = _saves_manager.read_offline_saves()
	var online_saves: Array[TaloGameSave] = []

	if await Talo.is_offline():
		saves.append_array(offline_saves)
	else:
		if Talo.identity_check() != OK:
			return []

		var res = await client.make_request(HTTPClient.METHOD_GET, "/")
		match (res.status):
			200:
				online_saves.append_array(res.body.saves.map(func (data: Dictionary): return TaloGameSave.new(data)))
				
				if not offline_saves.is_empty():
					for online_save in online_saves:
						var filtered = offline_saves.filter(func (save: TaloGameSave): return save.id == online_save.id)
						if not filtered.is_empty():
							await _saves_manager.sync_save(online_save, filtered.front())
					
					var synced_saves = await _saves_manager.sync_offline_saves(offline_saves)
					saves.append_array(synced_saves)
				
				saves.append_array(online_saves)
	
	_saves_manager.all_saves = saves
	saves_loaded.emit()

	for save in _saves_manager.all_saves:
		_saves_manager.update_offline_saves(save)

	return _saves_manager.all_saves

func set_chosen_save(save: TaloGameSave, load_save = true) -> void:
	_saves_manager.set_chosen_save(save, load_save)

func choose_save(save: TaloGameSave) -> void:
	set_chosen_save(save)

func unload_current_save() -> void:
	set_chosen_save(null)

func create_save(save_name: String, content: Dictionary = {}) -> TaloGameSave:
	var save: TaloGameSave

	_saves_manager.register_fields_for_saved_objects()
	var save_content = content if not content.is_empty() else _saves_manager.get_save_content()

	if await Talo.is_offline():
		save = TaloGameSave.new({
			name=save_name,
			content=save_content,
			updatedAt=TimeUtils.get_current_time_msec()
		})
	else:
		var res = await client.make_request(HTTPClient.METHOD_POST, "/", {
			name=save_name,
			content=save_content
		})

		match (res.status):
			200:
				save = TaloGameSave.new(res.body.save)
		
	_saves_manager.all_saves.push_back(save)
	_saves_manager.update_offline_saves(save)
	set_chosen_save(save)

	return save

func register(loadable: TaloLoadable) -> void:
	_saves_manager.register(loadable)

func set_object_loaded(id: String) -> void:
	_saves_manager.set_object_loaded(id)

func update_current_save(new_name: String = "") -> TaloGameSave:
	return await update_save(_saves_manager.current_save, new_name)

func update_save(save: TaloGameSave, new_name: String = "") -> TaloGameSave:
	var content = _saves_manager.get_save_content()

	if await Talo.is_offline():
		if not new_name.is_empty():
			save.display_name = new_name

		save.content = content
		save.updated_at = TimeUtils.get_current_time_msec()
	else:
		if Talo.identity_check() != OK:
			return

		var res = await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % save.id, {
			name=save.display_name if new_name.is_empty() else new_name,
			content=content
		})

		match (res.status):
			200:
				save = TaloGameSave.new(res.body.save)

	_saves_manager.replace_save(save)
	return save

func delete_save(save: TaloGameSave) -> void:
	if not await Talo.is_offline():
		if Talo.identity_check() != OK:
			return

		var res = await client.make_request(HTTPClient.METHOD_DELETE, "/%s" % save.id)

		match res.status:
			_:
				return
	
	_saves_manager.all_saves = _saves_manager.all_saves.filter(func (s: TaloGameSave): s.id != save.id)
	_saves_manager.delete_offline_save(save)

	if _saves_manager.current_save and _saves_manager.current_save.id == save.id:
		unload_current_save()
