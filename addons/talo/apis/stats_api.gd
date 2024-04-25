class_name StatsAPI extends TaloAPI

func track(internal_name: String, change: float = 1.0) -> void:
	Talo.identity_check()
	
	await client.make_request(HTTPClient.METHOD_PUT, "/%s" % internal_name, { change = change })
