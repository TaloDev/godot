extends Button

func _on_pressed() -> void:
	var name = "Save %s version 1" % [TaloTimeUtils.get_current_datetime_string()]
	await Talo.saves.create_save(name)
	%ResponseLabel.text = "Created save: %s" % name
