class_name LeaderboardsAPI extends TaloAPI

var _entries_manager = TaloLeaderboardEntriesManager.new()

func get_cached_entries(internal_name: String) -> Array:
	return _entries_manager.get_entries(internal_name)

func get_cached_entries_for_current_player(internal_name: String) -> Array:
	if Talo.identity_check() != OK:
		return []

	return _entries_manager.get_entries(internal_name).filter(
		func (entry: TaloLeaderboardEntry):
			return entry.player_alias.id == Talo.current_alias.id
	)

func get_entries(internal_name: String, page: int, alias_id = -1) -> Array:
	var url = "/%s/entries?page=%s"
	var url_data = [internal_name, page]

	if alias_id != -1:
		url += "&aliasId=%s"
		url_data += alias_id

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

func get_entries_for_current_player(internal_name: String, page: int) -> Array:
	if Talo.identity_check() != OK:
		return []
	
	return await get_entries(internal_name, page, Talo.current_alias.id)

func add_entry(internal_name: String, score: float) -> Array:
	if Talo.identity_check() != OK:
		return []

	var res = await client.make_request(HTTPClient.METHOD_POST, "/%s/entries" % internal_name, { score = score })

	match (res.status):
		200:
			var entry = TaloLeaderboardEntry.new(res.body.entry)
			_entries_manager.upsert_entry(internal_name, entry)

			return [entry, res.body.updated]
		_:
			return []
