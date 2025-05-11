extends Button

@export var leaderboard_name: String

func _on_pressed() -> void:
	if leaderboard_name.is_empty():
		%ResponseLabel.text = "leaderboard_name not set on GetEntriesButton"
		return

	var options := Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0
	var res := await Talo.leaderboards.get_entries(leaderboard_name, options)

	if is_instance_valid(res):
		var entries := res.entries
		%ResponseLabel.text = "Received %s entries" % entries.size()
	else:
		%ResponseLabel.text = "No entries found for %s" % leaderboard_name
