extends Button

func _on_pressed() -> void:
	var saves: Array[TaloGameSave] = Talo.saves.all

	if saves.is_empty():
		print("No saves, fetching...")
		saves = await Talo.saves.get_saves()

		if saves.is_empty():
			push_warning("No saves to load")
			return

	Talo.saves.choose_save(Talo.saves.latest)
