extends Button

func _on_pressed() -> void:
	if not Talo.saves.current:
		push_error("No save currently loaded")
		return

	var version = 0

	var regex = RegEx.new()
	regex.compile("version\\s+(\\d+)")

	var result = regex.search(Talo.saves.current.display_name)
	if result:
		version = int(result.get_string(1))

	var new_name = Talo.saves.current.display_name.replace("version %s" % version, "version %s" % (version + 1))

	Talo.saves.update_current_save(new_name)
