extends Button

func _on_pressed() -> void:
	var saves := Talo.saves.all

	if saves.is_empty():
		%ResponseLabel.text = "No saves found, fetching..."
		saves = await Talo.saves.get_saves()

		if saves.is_empty():
			push_warning("No saves to load")
			%ResponseLabel.text = "No saves to load"
			return

	await Talo.saves.choose_save(Talo.saves.latest)
	%ResponseLabel.text = "Loaded %s" % Talo.saves.latest.name
