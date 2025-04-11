extends Button

func _on_pressed() -> void:
	if not Talo.saves.current:
		%ResponseLabel.text = "No save currently loaded"
		return

	var version := 0

	var regex := RegEx.new()
	regex.compile("version\\s+(\\d+)")

	var result := regex.search(Talo.saves.current.name)
	if result:
		version = int(result.get_string(1))

	var new_name := Talo.saves.current.name.replace("version %s" % version, "version %s" % (version + 1))

	await Talo.saves.update_current_save(new_name)
	%ResponseLabel.text = "Updated save, new name is: %s" % new_name
