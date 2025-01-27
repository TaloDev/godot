class_name PlayersAPI extends TaloAPI
## An interface for communicating with the Talo Players API.
##
## This API is used to identify players and update player data.
##
## @tutorial: https://docs.trytalo.com/docs/godot/identifying

## Emitted when a player has been identified.
signal identified(player: TaloPlayer)

## Identify a player using a service (e.g. "username") and identifier (e.g. "bob").
func identify(service: String, identifier: String) -> void:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/identify?service=%s&identifier=%s" % [service, identifier])
	match (res.status):
		200:
			Talo.current_alias = TaloPlayerAlias.new(res.body.alias)
			Talo.socket.set_socket_token(res.body.socketToken)
			identified.emit(Talo.current_player)
		_:
			if not await Talo.is_offline():
				Talo.player_auth.session_manager.clear_session()

## Identify a player using a Steam ticket.
func identify_steam(ticket: String, identity: String = "") -> void:
	if identity.is_empty():
		identify("steam", ticket)
	else:
		identify("steam", "%s:%s" % [identity, ticket])

## Flush and sync the player's current data with Talo.
func update() -> void:
	var res = await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % Talo.current_player.id, { props = Talo.current_player.get_serialized_props() })
	match (res.status):
		200:
			Talo.current_alias.player = TaloPlayer.new(res.body.player)

## Merge all of the data from player_id2 into player_id1 and delete player_id2.
func merge(player_id1: String, player_id2: String) -> TaloPlayer:
	var res = await client.make_request(HTTPClient.METHOD_POST, "/merge", {
		playerId1 = player_id1,
		playerId2 = player_id2
	})

	match (res.status):
		200:
			return TaloPlayer.new(res.body.player)
		_:
			return null

## Get a player by their ID.
func find(player_id: String) -> TaloPlayer:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/%s" % player_id)
	match (res.status):
		200:
			return TaloPlayer.new(res.body.player)
		_:
			return null

## Generate a mostly-unique identifier.
func generate_identifier() -> String:
	var time_hash: String = str(TimeUtils.get_timestamp_msec()).sha256_text()
	var size = 12
	var split_start: int = RandomNumberGenerator.new().randi_range(0, time_hash.length() - size)
	return time_hash.substr(split_start, size)
