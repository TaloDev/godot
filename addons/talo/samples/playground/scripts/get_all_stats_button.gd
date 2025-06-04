extends Button

func _on_pressed() -> void:
	var res := await Talo.stats.get_stats()
	var all_stats := PackedStringArray(res.map(func (item: TaloStat): return item.internal_name))
	var internal_names := ", ".join(all_stats) if all_stats.size() > 0 else "no stats"
	%ResponseLabel.text = "Stats: %s" % [internal_names]
