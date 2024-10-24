extends Button

@export var prop_name: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if prop_name.is_empty():
		%ResponseLabel.text = "prop_name not set on DeletePropButton"
		return

	Talo.current_player.delete_prop(prop_name)
