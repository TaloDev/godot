extends Button

@export var stat_name: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on TrackStatButton"
		return

	Talo.stats.track(stat_name)
	%ResponseLabel.text = "Stat incremented: %s" % stat_name
