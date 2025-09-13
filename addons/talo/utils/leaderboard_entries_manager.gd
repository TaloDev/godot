class_name TaloLeaderboardEntriesManager extends RefCounted

# String -> Array[TaloLeaderboardEntry]
# TODO: update when nested typed collections are supported
var _current_entries: Dictionary = {}

func get_entries(internal_name: String) -> Array[TaloLeaderboardEntry]:
	return _current_entries.get(internal_name, Array([], TYPE_OBJECT, "RefCounted", TaloLeaderboardEntry))

func _compare_entries(a: TaloLeaderboardEntry, b: TaloLeaderboardEntry) -> bool:
	# first compare by score based on sort mode
	if a.score != b.score:
		if a.leaderboard_sort_mode == TaloLeaderboardEntry.LeaderboardSortMode.ASC:
			return a.score < b.score
		else:
			return a.score > b.score
	
	# if scores are equal, earlier entries win
	return a.created_at < b.created_at

func _find_insert_position(entries: Array[TaloLeaderboardEntry], entry: TaloLeaderboardEntry) -> int:
	var left = 0
	var right = entries.size()
	
	while left < right:
		var mid = (left + right) / 2
		if _compare_entries(entries[mid], entry):
			left = mid + 1
		else:
			right = mid
	
	return left

func upsert_entry(internal_name: String, entry: TaloLeaderboardEntry) -> void:
	var named_entries: Array[TaloLeaderboardEntry] = []
	named_entries = _current_entries.get_or_add(internal_name, named_entries).filter(
		func (e: TaloLeaderboardEntry) -> bool: return e.id != entry.id
	)

	var insert_pos = _find_insert_position(named_entries, entry)
	named_entries.insert(insert_pos, entry)
	
	for idx in range(named_entries.size()):
		named_entries[idx].position = idx

	_current_entries[internal_name] = named_entries
