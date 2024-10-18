extends Button

func _on_pressed() -> void:
	if not Talo.saves.current:
		push_error("No save currently loaded")
		return

	Talo.saves.delete_save(Talo.saves.current)
