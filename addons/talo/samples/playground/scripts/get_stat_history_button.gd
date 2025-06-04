extends Button

@export var stat_name: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on GetStatHistoryButton"
		return

	var res := await Talo.stats.get_history(stat_name)
	var changes := PackedStringArray(res.history.map(func (item): return str(item.change)))
	var change_string := ", ".join(changes) if changes.size() > 0 else "no changes"

	%ResponseLabel.text = "%s changed by: %s" % [stat_name, change_string]
