extends Button

@export var stat_name: String
@export var player_id: String

func _on_pressed() -> void:
	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on GetGlobalHistoryButton"
		return

	var res := await Talo.stats.get_global_history(stat_name, 0, player_id)
	if res:
		var global_metrics := res.global_value
		var player_metrics := res.player_value

		%ResponseLabel.text = "Min: %s, max: %s, median: %s, average: %s, average change: %s, average player value: %s" % [
			global_metrics.min_value,
			global_metrics.max_value,
			global_metrics.median_value,
			global_metrics.average_value,
			global_metrics.average_change,
			player_metrics.average_value
		]
	else:
		%ResponseLabel.text = "Could not fetch global history, is your stat global?"
