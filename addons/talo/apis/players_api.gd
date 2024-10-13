class_name PlayersAPI extends TaloAPI

signal identified(player: TaloPlayer)

func identify(service: String, identifier: String) -> void:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/identify?service=%s&identifier=%s" % [service, identifier])
	match (res.status):
		200:
			Talo.current_alias = TaloPlayerAlias.new(res.body.alias)
			identified.emit(Talo.current_player)
		_:
			Talo.player_auth.session_manager.clear_session()

func identify_steam(ticket: String, identity: String = "") -> void:
	if identity.is_empty():
		identify("steam", ticket)
	else:
		identify("steam", "%s:%s" % [identity, ticket])

func update() -> void:
	var res = await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % Talo.current_player.id, { props = Talo.current_player.get_serialized_props() })
	match (res.status):
		200:
			Talo.current_alias.player = TaloPlayer.new(res.body.player)

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
