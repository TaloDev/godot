extends Button

@export var stat_name: String

func _on_pressed() -> void:
	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on GetPlayerStatButton"
		return

	var res := await Talo.stats.find_player_stat(stat_name)

	%ResponseLabel.text = "%s value: %s, last updated: %s" % [
		stat_name,
		"not set" if res == null else res.value,
		"never" if res == null else res.updated_at
	]
