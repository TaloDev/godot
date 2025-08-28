class_name TaloLiveConfig extends RefCounted
## The live config is a set of key-value pairs that can be updated in the Talo dashboard.
##
## @tutorial: https://docs.trytalo.com/docs/godot/live-config

const _OFFLINE_DATA_PATH = "user://tlc.bin"

var props: Array[TaloProp] = []

var _offline_data: Array

func _init(props: Array):
	self.props.assign(props.map(func (prop): return TaloProp.new(prop.key, prop.value)))
	_offline_data = props

## Get a property value by key. Returns the fallback value if the key is not found.
func get_prop(key: String, fallback: String) -> String:
	var filtered := props.filter(func (prop: TaloProp): return prop.key == key)
	return fallback if filtered.is_empty() else filtered.front().value

## Cache the offline live config data.
func write_offline_config():
	var file := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.WRITE, Talo.crypto_manager.get_key())
	file.store_line(JSON.stringify(_offline_data))
	file.close()

## Get the offline live config data.
static func get_offline_config() -> TaloLiveConfig:
	if not FileAccess.file_exists(_OFFLINE_DATA_PATH):
		return null

	var file := FileAccess.open_encrypted_with_pass(_OFFLINE_DATA_PATH, FileAccess.READ, Talo.crypto_manager.get_key())
	if file == null:
		TaloCryptoManager.handle_undecryptable_file(_OFFLINE_DATA_PATH, "offline live config file")
		return null

	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()

	return TaloLiveConfig.new(json.data)

## Get the last modified time of the offline live config file.
func get_offline_config_last_modified() -> int:
	if not FileAccess.file_exists(_OFFLINE_DATA_PATH):
		return 0

	var modified_time := FileAccess.get_modified_time(_OFFLINE_DATA_PATH)
	return modified_time if typeof(modified_time) == TYPE_INT else 0
