extends Button

func _on_pressed() -> void:
	Talo.identity_check()

	Talo.current_player.set_prop("health", str(RandomNumberGenerator.new().randi_range(1, 100)))
