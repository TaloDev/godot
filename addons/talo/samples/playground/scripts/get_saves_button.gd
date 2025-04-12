extends Button

func _on_pressed() -> void:
	var saves = await Talo.saves.get_saves()
	%ResponseLabel.text = "Found %s saves" % saves.size()
