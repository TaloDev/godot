extends Node2D

signal email_change_success
signal go_to_game

@onready var password: TextEdit = %Password
@onready var new_email: TextEdit = %NewEmail
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not password.text:
		validation_label.text = "Current password is required"
		return

	if not new_email.text:
		validation_label.text = "New email is required"
		return

	var res = await Talo.player_auth.change_email(password.text, new_email.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Current password is incorrect"
			TaloAuthError.ErrorCode.NEW_EMAIL_MATCHES_CURRENT_EMAIL:
				validation_label.text = "New email must be different from the current email"
			TaloAuthError.ErrorCode.INVALID_EMAIL:
				validation_label.text = "Invalid email address"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		email_change_success.emit()

func _on_cancel_pressed() -> void:
	go_to_game.emit()
