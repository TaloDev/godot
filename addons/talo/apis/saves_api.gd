class_name SavesAPI extends TaloAPI
## An interface for communicating with the Talo Saves API.
##
## This API allows you to save and load game data for your players. You can create, update, and delete saves, as well as load and unload them.
##
## @tutorial: https://docs.trytalo.com/docs/godot/saves

## Emitted when the player's saves have been fetched and received.
signal saves_loaded
## Emitted when a save has been chosen.
signal save_chosen(save: TaloGameSave)
## Emitted when the chosen save has finished loading.
signal save_loading_completed

var _saves_manager = TaloSavesManager.new()

## All of the player's fetched saves.
var all: Array[TaloGameSave]:
	get: return _saves_manager.all_saves

## The latest save that was updated.
var latest: TaloGameSave:
	get: return _saves_manager.get_latest_save()

## The current save that has been chosen.
var current: TaloGameSave:
	get: return _saves_manager.current_save

## Sync an offline save with an online save using the offline save data.
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

## Get all of the player's saves.
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
				saves.append_array(await _saves_manager.get_synced_saves(online_saves))
	
	_saves_manager.all_saves = saves
	saves_loaded.emit()

	for save in _saves_manager.all_saves:
		_saves_manager.update_offline_saves(save)

	return _saves_manager.all_saves

## Set the chosen save and optionally (default true) load it.
func choose_save(save: TaloGameSave, load_save = true) -> void:
	_saves_manager.set_chosen_save(save, load_save)

## Unload the current save.
func unload_current_save() -> void:
	_saves_manager.set_chosen_save(null, false)

## Create a new save with the given name and content.
func create_save(save_name: String, content: Dictionary = {}) -> TaloGameSave:
	var save: TaloGameSave

	_saves_manager.register_fields_for_saved_objects()
	var save_content = content if not content.is_empty() else _saves_manager.get_save_content()

	if await Talo.is_offline():
		save = TaloGameSave.new({
			name=save_name,
			content=save_content,
			updatedAt=TimeUtils.get_current_datetime_string()
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
	choose_save(save)

	return save

## Register a loadable object to be saved and loaded.
func register(loadable: TaloLoadable) -> void:
	_saves_manager.register(loadable)

## Mark an object as loaded.
func set_object_loaded(id: String) -> void:
	_saves_manager.set_object_loaded(id)

## Update the currently loaded save using the current state of the game and with the given name.
func update_current_save(new_name: String = "") -> TaloGameSave:
	return await update_save(_saves_manager.current_save, new_name)

## Update the given save using the current state of the game and with the given name.
func update_save(save: TaloGameSave, new_name: String = "") -> TaloGameSave:
	var content = _saves_manager.get_save_content()

	if await Talo.is_offline():
		if not new_name.is_empty():
			save.display_name = new_name

		save.content = content
		save.updated_at = TimeUtils.get_current_datetime_string()
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

## Delete the given save.
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
