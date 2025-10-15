class_name StatsAPI extends TaloAPI
## An interface for communicating with the Talo Stats API.
##
## This API is used to track player stats in your game. Stats are used to track player metrics both individually and globally.
##
## @tutorial: https://docs.trytalo.com/docs/godot/stats

## List all stats and their values.
func get_stats() -> Array[TaloStat]:
	var res := await client.make_request(HTTPClient.METHOD_GET, "")

	match res.status:
		200:
			var stats: Array[TaloStat] = []
			stats.assign(res.body.stats.map(func (stat: Dictionary): return TaloStat.new(stat)))
			return stats
		_:
			return []

## Get a stat by its internal name.
func find(internal_name: String) -> TaloStat:
	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s" % internal_name)

	match res.status:
		200:
			return TaloStat.new(res.body.stat)
		_:
			return null

## Get a player stat by the stat's internal name.
func find_player_stat(internal_name: String) -> TaloPlayerStat:
	if Talo.identity_check() != OK:
		return null

	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s/player-stat" % internal_name)

	match res.status:
		200:
			if res.body.playerStat == null:
				return null
			return TaloPlayerStat.new(res.body.playerStat)
		_:
			return null

## Track a stat for the current player. The stat will be updated by the change amount (default 1.0). Returns the updated player stat and global stat values.
func track(internal_name: String, change: float = 1.0) -> TaloPlayerStat:
	if Talo.identity_check() != OK:
		return

	var res := await client.make_request(HTTPClient.METHOD_PUT, "/%s" % internal_name, { change = change })

	match res.status:
		200:
			return TaloPlayerStat.new(res.body.playerStat)
		_:
			return null

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
	var url := "/%s/history?%s" % [internal_name, query_string]

	var res := await client.make_request(HTTPClient.METHOD_GET, url)

	match res.status:
		200:
			var history: Array[TaloPlayerStatSnapshot] = []
			history.assign(res.body.history.map(func (snapshot: Dictionary): return TaloPlayerStatSnapshot.new(snapshot)))
			return StatHistoryPage.new(history, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

## Get a paginated array of changes to a global stat over time. History items can be filtered by when they were tracked and by player.
func get_global_history(internal_name: String, page: int = 0, player_id = "", start_date: String = "", end_date: String = "") -> GlobalStatHistoryPage:
	var query_params := PackedStringArray(["page=%s" % page])
	if player_id != "":
		query_params.append("playerId=%s" % player_id)
	if start_date != "":
		query_params.append("startDate=%s" % start_date)
	if end_date != "":
		query_params.append("endDate=%s" % end_date)

	var query_string := "&".join(query_params)
	var url := "/%s/global-history?%s" % [internal_name, query_string]

	var res := await client.make_request(HTTPClient.METHOD_GET, url)

	match res.status:
		200:
			var history: Array[TaloPlayerStatSnapshot] = []
			history.assign(res.body.history.map(func (snapshot: Dictionary): return TaloPlayerStatSnapshot.new(snapshot)))
			return GlobalStatHistoryPage.new(
				history,
				res.body.globalValue,
				res.body.playerValue,
				res.body.count,
				res.body.itemsPerPage,
				res.body.isLastPage
			)
		_:
			return null

## Get all the current player's stats.
func list_player_stats() -> Array[TaloPlayerStat]:
	if Talo.identity_check() != OK:
		return []

	var res := await client.make_request(HTTPClient.METHOD_GET, "/player-stats")

	match res.status:
		200:
			var player_stats: Array[TaloPlayerStat] = []
			player_stats.assign(res.body.playerStats.map(func (player_stat: Dictionary): return TaloPlayerStat.new(player_stat)))
			return player_stats
		_:
			return []

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

class GlobalValueMetrics:
	var min_value: float
	var max_value: float
	var median_value: float
	var average_value: float
	var average_change: float

	func _init(data: Dictionary):
		min_value = data.minValue
		max_value = data.maxValue
		median_value = data.medianValue
		average_value = data.averageValue
		average_change = data.averageChange

class PlayerValueMetrics:
	var min_value: float
	var max_value: float
	var median_value: float
	var average_value: float

	func _init(data: Dictionary):
		min_value = data.minValue
		max_value = data.maxValue
		median_value = data.medianValue
		average_value = data.averageValue

class GlobalStatHistoryPage:
	var history: Array[TaloPlayerStatSnapshot]
	var global_value: GlobalValueMetrics
	var player_value: PlayerValueMetrics
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(history: Array[TaloPlayerStatSnapshot], global_value: Dictionary, player_value: Dictionary, count: int, items_per_page: int, is_last_page: bool) -> void:
		self.history = history
		self.global_value = GlobalValueMetrics.new(global_value)
		self.player_value = PlayerValueMetrics.new(player_value)
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page
