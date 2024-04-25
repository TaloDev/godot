class_name LeaderboardsAPI extends TaloAPI

func get_entries(internal_name: String, page: int, alias_id = -1) -> Array:
	var url = "/%s/entries?page=%s"
	var url_data = [internal_name, page]

	if alias_id != -1:
		url += "&aliasId=%s"
		url_data += alias_id

	var res = await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match (res.status):
		200:
			var entries: Array = res.body.entries.map(func (entry: Dictionary): return TaloLeaderboardEntry.new(entry))
			return [entries, res.body.count, res.body.isLastPage]
		_:
			return []

func get_entries_for_current_player(internal_name: String, page: int) -> Array:
	Talo.identity_check()
	
	return await get_entries(internal_name, page, Talo.current_alias.id)

func add_entry(internal_name: String, score: float) -> Array:
	Talo.identity_check()

	var res = await client.make_request(HTTPClient.METHOD_POST, "/%s/entries" % internal_name, { score = score })

	match (res.status):
		200:
			return [TaloLeaderboardEntry.new(res.body.entry), res.body.updated]
		_:
			return []
