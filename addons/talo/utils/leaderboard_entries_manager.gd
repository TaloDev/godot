class_name TaloLeaderboardEntriesManager extends Node

var _current_entries: Dictionary = {}

func get_entries(internal_name: String) -> Array:
	return _current_entries.get(internal_name, [])

func upsert_entry(internal_name: String, entry: TaloLeaderboardEntry) -> void:
	if not _current_entries.has(internal_name):
		_current_entries[internal_name] = []
	else:
		_current_entries[internal_name] = _current_entries[internal_name].filter(
			func (e: TaloLeaderboardEntry): return e.id != entry.id
		)

	if entry.position >= _current_entries[internal_name].size():
		_current_entries[internal_name].append(entry)
	else:
		_current_entries[internal_name].insert(entry.position, entry)

	for idx in range(entry.position, _current_entries[internal_name].size()):
		_current_entries[internal_name][idx].position = idx
