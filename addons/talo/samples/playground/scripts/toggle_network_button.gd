extends Button

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"

func _ready() -> void:
  _set_text(Talo.offline_mode_enabled())

func _set_text(offline: bool):
  text = "Go online" if offline else "Go offline"

func _on_pressed() -> void:
  var offline = Talo.offline_mode_enabled()

  Talo.config.set_value(
    "debug",
    "offline_mode",
    not offline
  )
  _set_text(not offline)
  response_label.text = "You are now " + ("offline" if not offline else "online")
