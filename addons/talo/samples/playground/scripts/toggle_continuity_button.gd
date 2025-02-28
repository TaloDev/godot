extends Button

func _ready() -> void:
	_set_text(_get_value())

func _get_value():
	return Talo.get_setting(Talo.Settings.CONTINUITY_ENABLED)

func _set_text(enabled: bool):
	text = "Toggle off" if enabled else "Toggle on"

func _on_pressed() -> void:
	var enabled = _get_value()

	Talo.set_setting(Talo.Settings.CONTINUITY_ENABLED, not enabled)
	_set_text(not enabled)
	%ResponseLabel.text = "Continuity is now " + ("enabled" if not enabled else "disabled")
