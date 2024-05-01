extends Button

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		return

	Talo.current_player.set_prop("health", str(RandomNumberGenerator.new().randi_range(1, 100)))
