extends Button

func _on_pressed() -> void:
	var categories = await Talo.feedback.get_categories()

	if categories.size() == 0:
		%ResponseLabel.text = "No categories found. Create some in the Talo dashboard!"
	else:
		var mapped = categories.map(func (c): return "%s (%s)" % [c.display_name, c.internal_name])
		%ResponseLabel.text = "Categories: " + ", ".join(mapped)
