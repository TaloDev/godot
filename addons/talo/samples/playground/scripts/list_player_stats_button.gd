extends Button

func _on_pressed() -> void:
	var res := await Talo.stats.list_player_stats()
	var values := PackedStringArray(
		res.map(
			func (item: TaloPlayerStat): return "%s = %s" % [item.stat.internal_name, item.value]
		)
	)
	var player_stat_values := ", ".join(values) if values.size() > 0 else "none"
	%ResponseLabel.text = "Player stats: %s" % [player_stat_values]
