extends Button

@export var stat_name: String
@export var player_id: String

func _on_pressed() -> void:
	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on GetGlobalHistoryButton"
		return

	var res := await Talo.stats.get_global_history(stat_name, 0, player_id)
	if res:
		var global_value := res.global_value

		%ResponseLabel.text = "Min: %s, max: %s, median: %s, average: %s, average change: %s" % [
			global_value.min_value,
			global_value.max_value,
			global_value.median_value,
			global_value.average_value,
			global_value.average_change
		]
	else:
		%ResponseLabel.text = "Could not fetch global history, is your stat global?"
