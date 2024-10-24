extends Button

@export var leaderboard_name: String

func _on_pressed() -> void:
	if leaderboard_name.is_empty():
		%ResponseLabel.text = "leaderboard_name not set on GetEntriesButton"
		return

	var res = await Talo.leaderboards.get_entries(leaderboard_name, 0)

	if res.size() > 0:
		var entries = res[0]
		%ResponseLabel.text = "Received %s entries" % entries.size()
	else:
		%ResponseLabel.text = "No entries found for %s" % leaderboard_name
