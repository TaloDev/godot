class_name LeaderboardsAPI extends TaloAPI
## An interface for communicating with the Talo Leaderboards API.
##
## This API is used to read and update leaderboards in your game. Leaderboards are used to track player scores and rankings.
##
## @tutorial: https://docs.trytalo.com/docs/godot/leaderboards

var _entries_manager = TaloLeaderboardEntriesManager.new()

## Get a list of all the entries that have been previously fetched or created for a leaderboard.
func get_cached_entries(internal_name: String) -> Array:
	return _entries_manager.get_entries(internal_name)

## Get a list of all the entries that have been previously fetched or created for a leaderboard for the current player.
func get_cached_entries_for_current_player(internal_name: String) -> Array:
	if Talo.identity_check() != OK:
		return []

	return _entries_manager.get_entries(internal_name).filter(
		func (entry: TaloLeaderboardEntry):
			return entry.player_alias.id == Talo.current_alias.id
	)

## Get a list of entries for a leaderboard. The page parameter is used for pagination.
func get_entries(internal_name: String, page: int, alias_id = -1, include_archived = false) -> Array:
	var url = "/%s/entries?page=%s"
	var url_data = [internal_name, page]

	if alias_id != -1:
		url += "&aliasId=%s"
		url_data += alias_id

	if include_archived:
		url += "&withDeleted=1"

	var res = await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match (res.status):
		200:
			var entries: Array = res.body.entries.map(
				func (data: Dictionary):
					var entry = TaloLeaderboardEntry.new(data)
					_entries_manager.upsert_entry(internal_name, entry)

					return entry
			)
			return [entries, res.body.count, res.body.isLastPage]
		_:
			return []

## Get a list of entries for a leaderboard for the current player. The page parameter is used for pagination.
func get_entries_for_current_player(internal_name: String, page: int, include_archived = false) -> Array:
	if Talo.identity_check() != OK:
		return []

	return await get_entries(internal_name, page, Talo.current_alias.id, include_archived)

## Add an entry to a leaderboard. The props (key-value pairs) parameter is used to store additional data with the entry.
func add_entry(internal_name: String, score: float, props: Dictionary = {}) -> Array:
	if Talo.identity_check() != OK:
		return []

	var props_to_send = props.keys().map(func (key: String): return { key = key, value = str(props[key]) })

	var res = await client.make_request(HTTPClient.METHOD_POST, "/%s/entries" % internal_name, {
		score = score,
		props = props_to_send
	})

	match (res.status):
		200:
			var entry = TaloLeaderboardEntry.new(res.body.entry)
			_entries_manager.upsert_entry(internal_name, entry)

			return [entry, res.body.updated]
		_:
			return []
