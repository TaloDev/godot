class_name GameConfigAPI extends TaloAPI
## An interface for communicating with the Talo Live Config API.
##
## This API is used to fetch the live config for your game. The live config is a set of key-value pairs that can be updated in the Talo dashboard.
##
## @tutorial: https://docs.trytalo.com/docs/godot/live-config

## Emitted when the live config has been loaded.
signal live_config_loaded(live_config: TaloLiveConfig)

## Emitted when the live config has been updated.
signal live_config_updated(live_config: TaloLiveConfig)

func _ready() -> void:
	await Talo.init_completed
	Talo.socket.message_received.connect(_on_message_received)

func _on_message_received(res: String, data: Dictionary) -> void:
	if res == "v1.live-config.updated":
		_handle_new_live_config(TaloLiveConfig.new(data.config), true)

func _handle_new_live_config(new_live_config: TaloLiveConfig, updated: bool = false) -> TaloLiveConfig:
	Talo.live_config = new_live_config

	if updated:
		live_config_updated.emit(new_live_config)
	else:
		live_config_loaded.emit(new_live_config)

	if not await Talo.is_offline():
		new_live_config.write_offline_config()

	return new_live_config

## Get the live config for your game.
func get_live_config() -> TaloLiveConfig:
	if await Talo.is_offline():
		var offline_config := TaloLiveConfig.get_offline_config()
		if offline_config != null:
			return await _handle_new_live_config(offline_config)
		else:
			return null

	var res := await client.make_request(HTTPClient.METHOD_GET, "/")
	match res.status:
		200:
			return await _handle_new_live_config(TaloLiveConfig.new(res.body.config))
		_:
			return null
