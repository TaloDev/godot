class_name TaloLeaderboardEntriesManager extends RefCounted

var _current_entries: Dictionary = {} # String -> Array[TaloLeaderboardEntry]

func get_entries(internal_name: String) -> Array[TaloLeaderboardEntry]:
	return Array(_current_entries.get(internal_name, []), TYPE_OBJECT, (TaloLeaderboardEntry as Script).get_instance_base_type(), TaloLeaderboardEntry)

func upsert_entry(internal_name: String, entry: TaloLeaderboardEntry) -> void:
	var named_entries :Array[TaloLeaderboardEntry]
	named_entries = _current_entries.get_or_add(internal_name, named_entries).filter(
		func (e: TaloLeaderboardEntry) -> bool: return e.id != entry.id
	)

	if entry.position >= named_entries.size():
		named_entries.append(entry)
	else:
		named_entries.insert(entry.position, entry)

	for idx in range(entry.position, named_entries.size()):
		named_entries[idx].position = idx
