class_name StatsAPI extends TaloAPI
## An interface for communicating with the Talo Stats API.
##
## This API is used to track player stats in your game. Stats are used to track player metrics both individually and globally.
##
## @tutorial: https://docs.trytalo.com/docs/godot/stats

## Track a stat for the current player. The stat will be updated by the change amount (default 1.0). Returns the updated player stat and global stat values.
func track(internal_name: String, change: float = 1.0) -> TaloPlayerStat:
	if Talo.identity_check() != OK:
		return
	
	var res = await client.make_request(HTTPClient.METHOD_PUT, "/%s" % internal_name, { change = change })
	return TaloPlayerStat.new(res.body)

## Get a paginated array of changes to a player stat value (and its global value) over time. History items can be filtered by when they were tracked.
func get_history(internal_name: String, page: int = 0, start_date: String = "", end_date: String = "") -> StatHistoryPage:
	if Talo.identity_check() != OK:
		return null

	var query_params := PackedStringArray(["page=%s" % page])
	if start_date != "":
		query_params.append("startDate=%s" % start_date)
	if end_date != "":
		query_params.append("endDate=%s" % end_date)

	var query_string := "&".join(query_params)
	var url = "/%s/history?%s" % [internal_name, query_string]

	var res = await client.make_request(HTTPClient.METHOD_GET, url)

	match res.status:
		200:
			var history: Array[TaloPlayerStatSnapshot] = []
			history.assign(res.body.history.map(func (snapshot: Dictionary): return TaloPlayerStatSnapshot.new(snapshot)))
			return StatHistoryPage.new(history, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

class StatHistoryPage:
	var history: Array[TaloPlayerStatSnapshot]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(history: Array[TaloPlayerStatSnapshot], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.history = history
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page
