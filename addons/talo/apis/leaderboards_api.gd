class_name LeaderboardsAPI extends TaloAPI
## An interface for communicating with the Talo Leaderboards API.
##
## This API is used to read and update leaderboards in your game. Leaderboards are used to track player scores and rankings.
##
## @tutorial: https://docs.trytalo.com/docs/godot/leaderboards

var _entries_manager := TaloLeaderboardEntriesManager.new()

## Get a list of all the entries that have been previously fetched or created for a leaderboard.
func get_cached_entries(internal_name: String) -> Array[TaloLeaderboardEntry]:
	return _entries_manager.get_entries(internal_name)

## Get a list of all the entries that have been previously fetched or created for a leaderboard for the current player.
func get_cached_entries_for_current_player(internal_name: String) -> Array[TaloLeaderboardEntry]:
	if Talo.identity_check() != OK:
		return []

	return _entries_manager.get_entries(internal_name).filter(
		func (entry: TaloLeaderboardEntry) -> bool:
			return entry.player_alias.id == Talo.current_alias.id
	)

## Get a list of entries for a leaderboard. The options include "page", "alias_id", "include_archived", "prop_key", "prop_value", "start_date" and "end_date" for additional filtering.
func get_entries(internal_name: String, options := GetEntriesOptions.new()) -> EntriesPage:
	var url := "/%s/entries?page=%s"
	var url_data := [internal_name, options.page]

	if options.alias_id != -1:
		url += "&aliasId=%s"
		url_data.append(options.alias_id)

	if options.include_archived:
		url += "&withDeleted=1"

	if options.prop_key != "":
		url += "&propKey=%s"
		url_data.append(options.prop_key)

		if options.prop_value != "":
			url += "&propValue=%s"
			url_data.append(options.prop_value)

	if options.start_date != "":
		url += "&startDate=%s"
		url_data.append(options.start_date)

	if options.end_date != "":
		url += "&endDate=%s"
		url_data.append(options.end_date)

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var entries: Array[TaloLeaderboardEntry] = Array(res.body.entries.map(
				func (data: Dictionary):
					var entry := TaloLeaderboardEntry.new(data)
					_entries_manager.upsert_entry(internal_name, entry)

					return entry
			), TYPE_OBJECT, (TaloLeaderboardEntry as Script).get_instance_base_type(), TaloLeaderboardEntry)
			return EntriesPage.new(entries, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

func get_entries_for_current_player(internal_name: String, options := GetEntriesOptions.new()) -> EntriesPage:
	if Talo.identity_check() != OK:
		return null

	options.alias_id = Talo.current_alias.id

	return await get_entries(internal_name, options)

## Add an entry to a leaderboard. The props (key-value pairs) parameter is used to store additional data with the entry.
func add_entry(internal_name: String, score: float, props: Dictionary[String, Variant] = {}) -> AddEntryResult:
	if Talo.identity_check() != OK:
		return null

	var res := await client.make_request(HTTPClient.METHOD_POST, "/%s/entries" % internal_name, {
		score = score,
		props = TaloPropUtils.dictionary_to_array(props)
	})

	match res.status:
		200:
			var entry = TaloLeaderboardEntry.new(res.body.entry)
			_entries_manager.upsert_entry(internal_name, entry)

			return AddEntryResult.new(entry, res.body.updated)
		_:
			return null

class EntriesPage:
	var entries: Array[TaloLeaderboardEntry]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(entries: Array[TaloLeaderboardEntry], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.entries = entries
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page

class AddEntryResult:
	var entry: TaloLeaderboardEntry
	var updated: bool

	func _init(entry: TaloLeaderboardEntry, updated: bool) -> void:
		self.entry = entry
		self.updated = updated

class GetEntriesOptions:
	var page: int = 0
	var alias_id: int = -1
	var include_archived: bool = false
	var prop_key: String = ""
	var prop_value: String = ""
	var start_date: String = ""
	var end_date: String = ""
