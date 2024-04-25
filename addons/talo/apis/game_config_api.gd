class_name GameConfigAPI extends TaloAPI

signal live_config_loaded(live_config: TaloLiveConfig)

func get_live_config() -> void:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/")
	match (res.status):
		200:
			Talo.live_config = TaloLiveConfig.new(res.body.config)
			live_config_loaded.emit(Talo.live_config)
