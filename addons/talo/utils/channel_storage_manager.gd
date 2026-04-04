class_name TaloChannelStorageManager extends RefCounted

var _entities: Dictionary[int, TaloEntityWithProps] = {}

func _get_entity(channel_id: int) -> TaloEntityWithProps:
	if !_entities.has(channel_id):
		_entities[channel_id] = TaloEntityWithProps.new([])
	return _entities[channel_id]

func on_props_updated(channel: TaloChannel, upserted_props: Array[TaloChannelStorageProp], deleted_props: Array[TaloChannelStorageProp]) -> void:
	upsert_many_props(channel.id, upserted_props)

	for prop in deleted_props:
		delete_prop(channel.id, prop.key)

func get_prop(channel_id: int, key: String) -> TaloChannelStorageProp:
	var entity := _get_entity(channel_id)
	var cached: Array[TaloChannelStorageProp] = []
	cached.assign(entity.find_props_by_key(key))
	if !cached.is_empty():
		return cached.front()

	return await Talo.channels.get_storage_prop(channel_id, key, true)

func list_props(channel_id: int, keys: Array[String]) -> Array[TaloChannelStorageProp]:
	var entity := _get_entity(channel_id)
	var result: Array[TaloChannelStorageProp] = []
	var keys_to_fetch: Array[String] = []

	for key in keys:
		var cached: Array[TaloChannelStorageProp] = []
		cached.assign(entity.find_props_by_key(key))
		if !cached.is_empty():
			result.append_array(cached)
		else:
			keys_to_fetch.append(key)

	if keys_to_fetch.size() > 0:
		var fetched_props := await Talo.channels.list_storage_props(channel_id, keys_to_fetch, true)
		for prop in fetched_props:
			upsert_prop(channel_id, prop)
			result.append(prop)

	return result

func upsert_prop(channel_id: int, prop: TaloChannelStorageProp, expand: bool = false) -> void:
	var props_to_upsert: Array[TaloChannelStorageProp] = [prop]

	if expand and prop.key.ends_with("[]"):
		var parsed: Variant = JSON.parse_string(prop.value)
		# create clones of the original prop with each value from the array
		if parsed is Array:
			props_to_upsert.clear()

			for v in parsed:
				var expanded := TaloChannelStorageProp.new_from_prop(prop, str(v))
				props_to_upsert.append(expanded)

	upsert_many_props(channel_id, props_to_upsert)

func upsert_many_props(channel_id: int, props: Array[TaloChannelStorageProp]) -> void:
	var entity := _get_entity(channel_id)
	var all_keys := props.map(func (p: TaloChannelStorageProp): return p.key)
	entity.props.assign(entity.props.filter(func (p: TaloProp): return p.key not in all_keys))

	for prop in props:
		entity.props.push_back(prop)

func delete_prop(channel_id: int, prop_key: String) -> void:
	_get_entity(channel_id).delete_prop(prop_key)
