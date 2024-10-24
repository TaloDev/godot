extends Button

@export var leaderboard_name: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if leaderboard_name.is_empty():
		%ResponseLabel.text = "leaderboard_name not set on AddEntryButton"
		return

	var score = RandomNumberGenerator.new().randi_range(1, 50)
	var res = await Talo.leaderboards.add_entry(leaderboard_name, score)

	if res.size() > 0:
		%ResponseLabel.text = "Added score: %s, new high score: %s" % [score, res[1]]
