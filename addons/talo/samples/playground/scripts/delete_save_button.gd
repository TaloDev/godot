extends Button

func _on_pressed() -> void:
	if not Talo.saves.current:
		%ResponseLabel.text = "No save currently loaded"
		return

	var name = Talo.saves.current.name

	await Talo.saves.delete_save(Talo.saves.current)
	%ResponseLabel.text = "Deleted save: %s" % name
