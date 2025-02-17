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
		live_config_updated.emit(TaloLiveConfig.new(data.config))

## Get the live config for your game.
func get_live_config() -> void:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/")
	match (res.status):
		200:
			Talo.live_config = TaloLiveConfig.new(res.body.config)
			live_config_loaded.emit(Talo.live_config)
