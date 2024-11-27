class_name GameConfigAPI extends TaloAPI
## An interface for communicating with the Talo Live Config API.
##
## This API is used to fetch the live config for your game. The live config is a set of key-value pairs that can be updated in the Talo dashboard.
##
## @tutorial: https://docs.trytalo.com/docs/godot/live-config

## Emitted when the live config has been loaded.
signal live_config_loaded(live_config: TaloLiveConfig)

## Get the live config for your game.
func get_live_config() -> void:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/")
	match (res.status):
		200:
			Talo.live_config = TaloLiveConfig.new(res.body.config)
			live_config_loaded.emit(Talo.live_config)
