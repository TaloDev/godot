class_name HealthCheckAPI extends TaloAPI

func ping() -> bool:
	var res = await client.make_request(HTTPClient.METHOD_GET, "")
	return res.status == 204
