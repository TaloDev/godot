extends Node

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	await Talo.events.flush()
	%ResponseLabel.text = "Events flushed"
