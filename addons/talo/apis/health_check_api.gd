class_name HealthCheckAPI extends TaloAPI
## An interface for communicating with the Talo Health Check API.
##
## This API is used to check if Talo can be reached by Continuity. You shouldn't need to use this API directly in your game.
##
## @tutorial: https://docs.trytalo.com/docs/godot/continuity

## Ping the Talo Health Check API to check if Talo can be reached.
func ping() -> bool:
	var res = await client.make_request(HTTPClient.METHOD_GET, "")
	return res.status == 204
