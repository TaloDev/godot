extends Button

@export var internal_name: String
@export var feedback_comment: String

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"

func _on_pressed() -> void:
  await Talo.feedback.send(internal_name, feedback_comment)
  response_label.text = "Feedback sent for %s: %s" % [internal_name, feedback_comment]
