extends Button

func _on_pressed() -> void:
	Talo.saves.create_save("Save %s version 1" % [TaloTimeUtils.get_current_datetime_string()])
