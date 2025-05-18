class_name TaloLeaderboardEntriesManager extends RefCounted

# String -> Array[TaloLeaderboardEntry]
# TODO: update when nested typed collections are supported
var _current_entries: Dictionary = {}

func get_entries(internal_name: String) -> Array[TaloLeaderboardEntry]:
	return _current_entries.get(internal_name, Array([], TYPE_OBJECT, "RefCounted", TaloLeaderboardEntry))

func upsert_entry(internal_name: String, entry: TaloLeaderboardEntry) -> void:
	var named_entries: Array[TaloLeaderboardEntry] = []
	named_entries = _current_entries.get_or_add(internal_name, named_entries).filter(
		func (e: TaloLeaderboardEntry) -> bool: return e.id != entry.id
	)

	if entry.position >= named_entries.size():
		named_entries.append(entry)
	else:
		named_entries.insert(entry.position, entry)

	for idx in range(entry.position, named_entries.size()):
		named_entries[idx].position = idx

	_current_entries[internal_name] = named_entries
