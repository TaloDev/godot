extends Node2D

signal password_reset_success
signal go_to_forgot_password

@onready var code: TextEdit = %Code
@onready var new_password: TextEdit = %NewPassword
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not code.text:
		validation_label.text = "Code is required"
		return

	if not new_password.text:
		validation_label.text = "New password is required"
		return

	var res = await Talo.player_auth.reset_password(code.text, new_password.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.PASSWORD_RESET_CODE_INVALID:
				validation_label.text = "Reset code is invalid"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		password_reset_success.emit()

func _on_cancel_pressed() -> void:
	go_to_forgot_password.emit()
