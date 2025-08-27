extends Button

# see signal connections in identified_label.gd and identified_state.gd
func _on_pressed() -> void:
	Talo.players.clear_identity()
