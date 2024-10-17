extends Node2D

signal verification_required
signal go_to_forgot_password
signal go_to_register

@onready var username: TextEdit = %Username
@onready var password: TextEdit = %Password
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not username.text:
		validation_label.text = "Username is required"
		return

	if not password.text:
		validation_label.text = "Password is required"
		return

	var res = await Talo.player_auth.login(username.text, password.text)
	if res[0] != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Username or password is incorrect"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		if res[1]:
			verification_required.emit()

func _on_forgot_password_pressed() -> void:
	go_to_forgot_password.emit()

func _on_register_pressed() -> void:
	go_to_register.emit()
