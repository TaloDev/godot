class_name TaloChannelStorageManager extends RefCounted

var _current_props: Dictionary[String, TaloChannelStorageProp] = {}

func on_props_updated(channel: TaloChannel, upserted_props: Array[TaloChannelStorageProp], deleted_props: Array[TaloChannelStorageProp]) -> void:
	for prop in upserted_props:
		upsert_prop(channel.id, prop)

	for prop in deleted_props:
		delete_prop(channel.id, prop.key)

func get_prop(channel_id: int, key: String) -> TaloChannelStorageProp:
	var cached_prop = _current_props.get("%s:%s" % [channel_id, key])
	if cached_prop:
		return cached_prop

	return await Talo.channels.get_storage_prop(channel_id, key, true)

func upsert_prop(channel_id: int, prop: TaloChannelStorageProp) -> void:
	var key := "%s:%s" % [channel_id, prop.key]
	_current_props.set(key, prop)

func delete_prop(channel_id: int, prop_key: String) -> void:
	var key := "%s:%s" % [channel_id, prop_key]
	_current_props.erase(key)
