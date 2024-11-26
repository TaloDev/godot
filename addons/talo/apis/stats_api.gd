class_name StatsAPI extends TaloAPI
## An interface for communicating with the Talo Stats API.
##
## This API is used to track player stats in your game. Stats are used to track player metrics both individually and globally.
##
## @tutorial: https://docs.trytalo.com/docs/godot/stats

## Track a stat for the current player. The stat will be updated by the change amount (default 1.0).
func track(internal_name: String, change: float = 1.0) -> void:
	if Talo.identity_check() != OK:
		return
	
	await client.make_request(HTTPClient.METHOD_PUT, "/%s" % internal_name, { change = change })
