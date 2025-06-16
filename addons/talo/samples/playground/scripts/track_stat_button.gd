extends Button

@export var stat_name: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on TrackStatButton"
		return

	var res := await Talo.stats.track(stat_name)
	if not is_instance_valid(res):
		%ResponseLabel.text = "Failed to track %s" % stat_name
		return

	%ResponseLabel.text = "Stat incremented: %s, new value is %s" % [stat_name, res.value]
