extends Button

var level = 1

func _on_pressed() -> void:
	level += 1

	Talo.events.track("Levelled up", {
		"New level": level
	})
