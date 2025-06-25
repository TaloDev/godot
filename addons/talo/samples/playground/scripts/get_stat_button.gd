extends Button

@export var stat_name: String

func _on_pressed() -> void:
	if stat_name.is_empty():
		%ResponseLabel.text = "stat_name not set on GetStatButton"
		return

	var res := await Talo.stats.find(stat_name)

	%ResponseLabel.text = "%s is%s a global stat, with a default value of %s" % [res.name, "" if res.global else " not", res.default_value]
