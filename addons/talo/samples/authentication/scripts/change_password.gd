extends Node2D

signal password_change_success
signal go_to_game

@onready var current_password: TextEdit = %CurrentPassword
@onready var new_password: TextEdit = %NewPassword
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not current_password.text:
		validation_label.text = "Current password is required"
		return

	if not new_password.text:
		validation_label.text = "New password is required"
		return

	var res := await Talo.player_auth.change_password(current_password.text, new_password.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Current password is incorrect"
			TaloAuthError.ErrorCode.NEW_PASSWORD_MATCHES_CURRENT_PASSWORD:
				validation_label.text = "New password must be different from the current password"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		password_change_success.emit()

func _on_cancel_pressed() -> void:
	go_to_game.emit()
