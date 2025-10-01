class_name PlayersAPI extends TaloAPI
## An interface for communicating with the Talo Players API.
##
## This API is used to identify players and update player data.
##
## @tutorial: https://docs.trytalo.com/docs/godot/identifying

## Emitted when a player has been identified.
signal identified(player: TaloPlayer)

## Emitted when identification starts.
signal identification_started()

## Emitted when identification fails.
signal identification_failed()

## Emitted after calling clear_identity().
signal identity_cleared()

func _ready() -> void:
	Talo.connection_restored.connect(_on_connection_restored)

func _handle_identify_success(alias: TaloPlayerAlias, socket_token: String = "") -> TaloPlayer:
	if not await Talo.is_offline():
		Talo.socket.reset_connection()

	Talo.current_alias = alias

	if not socket_token.is_empty():
		Talo.socket.set_socket_token(socket_token)

	identified.emit(Talo.current_player)
	return Talo.current_player

## Identify a player using a service (e.g. "username") and identifier (e.g. "bob").
func identify(service: String, identifier: String) -> TaloPlayer:
	identification_started.emit()

	if await Talo.is_offline():
		return await identify_offline(service, identifier)

	var res := await client.make_request(HTTPClient.METHOD_GET, "/identify?service=%s&identifier=%s" % [service, identifier])
	match res.status:
		200:
			var alias = TaloPlayerAlias.new(res.body.alias)
			alias.write_offline_alias()
			return await _handle_identify_success(alias, res.body.socketToken)
		_:
			Talo.player_auth.session_manager.clear_session()
			identification_failed.emit()
			return null

## Identify a player using a Steam ticket.
func identify_steam(ticket: String, identity: String = "") -> TaloPlayer:
	if identity.is_empty():
		return await identify("steam", ticket)
	else:
		return await identify("steam", "%s:%s" % [identity, ticket])

## Flush and sync the player's current data with Talo.
func update() -> TaloPlayer:
	if Talo.identity_check() != OK:
		return null

	var res := await client.make_request(HTTPClient.METHOD_PATCH, "/%s" % Talo.current_player.id, { props = Talo.current_player.get_serialized_props() })
	match res.status:
		200:
			if is_instance_valid(Talo.current_alias.player):
				Talo.current_alias.player.update_from_raw_data(res.body.player)
			else:
				Talo.current_alias.player = TaloPlayer.new(res.body.player)

			Talo.current_alias.write_offline_alias()
			return Talo.current_player
		_:
			return null

## Merge all of the data from player_id2 into player_id1 and delete player_id2.
func merge(player_id1: String, player_id2: String) -> TaloPlayer:
	var res := await client.make_request(HTTPClient.METHOD_POST, "/merge", {
		playerId1 = player_id1,
		playerId2 = player_id2
	})

	match res.status:
		200:
			return TaloPlayer.new(res.body.player)
		_:
			return null

## Get a player by their ID.
func find(player_id: String) -> TaloPlayer:
	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s" % player_id)
	match res.status:
		200:
			return TaloPlayer.new(res.body.player)
		_:
			return null

## Generate a mostly-unique identifier.
func generate_identifier() -> String:
	var time_hash := str(TaloTimeUtils.get_timestamp_msec()).sha256_text()
	var size := 12
	var split_start := RandomNumberGenerator.new().randi_range(0, time_hash.length() - size)
	return time_hash.substr(split_start, size)

## Attempt to identify a player when they're offline.
func identify_offline(service: String, identifier: String) -> TaloPlayer:
	var offline_alias := TaloPlayerAlias.get_offline_alias()
	if offline_alias != null and offline_alias.matches_identify_request(service, identifier):
		return await _handle_identify_success(offline_alias)
	else:
		identification_failed.emit()
		return null

## Search for players by IDs, prop values and alias identifiers.
func search(query: String, page: int = 0) -> SearchPage:
	var encoded_query := query.strip_edges().uri_encode()
	var res := await client.make_request(HTTPClient.METHOD_GET, "/search?query=%s&page=%s" % [encoded_query, page])
	match res.status:
		200:
			var players: Array[TaloPlayer] = []
			players.assign(res.body.players.map(func (player: Dictionary): return TaloPlayer.new(player)))
			return SearchPage.new(players, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

## Clears the current player identity. Pending events and continuity requests will also be cleared.
func clear_identity() -> void:
	if Talo.identity_check() != OK:
		return

	Talo.current_alias.delete_offline_alias()

	# clears the alias and resets the socket (doesn't require auth)
	Talo.player_auth.session_manager.clear_session()

	Talo.events.clear_queue()
	Talo.continuity_manager.clear_requests()

	identity_cleared.emit()

## Create a new socket token. The Talo socket will use this token to identify the player.
func create_socket_token() -> String:
	if Talo.identity_check() != OK:
		return ""
	
	var res := await client.make_request(HTTPClient.METHOD_POST, "/socket-token")
	match res.status:
		200:
			return res.body.socketToken
		_:
			return ""

func _on_connection_restored():
	await Talo.socket.reset_connection()
	if Talo.identity_check(false) == OK:
		var socket_token := await create_socket_token()
		Talo.socket.set_socket_token(socket_token)

class SearchPage:
	var players: Array[TaloPlayer]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(players: Array[TaloPlayer], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.players = players
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page
