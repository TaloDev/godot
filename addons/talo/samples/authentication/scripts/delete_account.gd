extends Node2D

signal delete_account_success
signal go_to_game

@onready var current_password: TextEdit = %CurrentPassword
@onready var validation_label: Label = %ValidationLabel

func _on_delete_pressed() -> void:
	validation_label.text = ""

	if not current_password.text:
		validation_label.text = "Current password is required"
		return

	var res = await Talo.player_auth.delete_account(current_password.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Current password is incorrect"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		delete_account_success.emit()

func _on_cancel_pressed() -> void:
	go_to_game.emit()
