class_name PlayerPresenceAPI extends TaloAPI
## An interface for communicating with the Talo Player Presence API.
##
## This API is used to track and manage player presence in your game. Presence indicates whether players are online
## and their current status.
##
## @tutorial: https://docs.trytalo.com/docs/godot/player-presence

## Emitted when a player's presence status changes.
signal presence_changed(presence: TaloPlayerPresence, online_changed: bool, custom_status_changed: bool)

func _ready():
	await Talo.init_completed
	Talo.socket.message_received.connect(_on_message_received)

func _on_message_received(res: String, data: Dictionary) -> void:
	if res == "v1.players.presence.updated":
		presence_changed.emit(TaloPlayerPresence.new(data.presence), data.meta.onlineChanged, data.meta.customStatusChanged)

## Get the presence status for a specific player.
func get_presence(player_id: String) -> TaloPlayerPresence:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/%s" % player_id)

	match (res.status):
		200:
			return TaloPlayerPresence.new(res.body.presence)
		_:
			return null

## Update the presence status for the current player.
func update_presence(online: bool, custom_status: String = "") -> TaloPlayerPresence:
	if Talo.identity_check() != OK:
		return null

	var res = await client.make_request(HTTPClient.METHOD_PUT, "", {
		online = online,
		customStatus = custom_status
	})

	match (res.status):
		200:
			return TaloPlayerPresence.new(res.body.presence)
		_:
			return null
