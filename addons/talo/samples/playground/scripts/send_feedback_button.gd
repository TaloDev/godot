extends Button

@export var category_name: String
@export var feedback_comment: String = "There is a bug in the game somewhere, go find it"

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if category_name.is_empty() or feedback_comment.is_empty():
		%ResponseLabel.text = "category_name or feedback_comment not set on SendFeedbackButton"
		return

	await Talo.feedback.send(category_name, feedback_comment)
	%ResponseLabel.text = "Feedback sent for %s: %s" % [category_name, feedback_comment]
