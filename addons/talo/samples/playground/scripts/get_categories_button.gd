extends Button

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"

func _on_pressed() -> void:
  var categories = await Talo.feedback.get_categories()

  if categories.size() == 0:
    response_label.text = "No categories found. Create some in the Talo dashboard!"
  else:
    var mapped = categories.map(func (c): return "%s (%s)" % [c.display_name, c.internal_name])
    response_label.text = "Categories: " + ", ".join(mapped)
