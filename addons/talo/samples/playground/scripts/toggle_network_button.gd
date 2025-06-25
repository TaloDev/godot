extends Button

func _ready() -> void:
	_set_text(Talo.settings.offline_mode)

func _set_text(offline: bool):
	text = "Go online" if offline else "Go offline"

func _on_pressed() -> void:
	var offline := Talo.settings.offline_mode

	Talo.settings.offline_mode = not offline
	_set_text(not offline)
	%ResponseLabel.text = "You are now " + ("offline" if not offline else "online")
