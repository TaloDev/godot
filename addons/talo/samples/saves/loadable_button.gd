class_name LoadableButton extends TaloLoadable

var button: Button
var clicks: int = 0

func _ready() -> void:
	super()
	button = get_child(0)

func register_fields() -> void:
	register_field("clicks", clicks)

func _set_button_text() -> void:
	button.text = "%s clicks" % clicks

func on_loaded(data: Dictionary) -> void:
	clicks = data["clicks"]
	_set_button_text()

func _on_button_pressed() -> void:
	clicks += 1
	_set_button_text()
	await Talo.saves.update_current_save()
