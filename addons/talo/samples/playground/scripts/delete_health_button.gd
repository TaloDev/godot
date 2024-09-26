extends Button

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		return

	Talo.current_player.delete_prop("health")
