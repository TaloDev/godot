extends Node2D

signal go_to_login

@onready var username: TextEdit = %Username
@onready var password: TextEdit = %Password
@onready var enable_verification: CheckBox = %EnableVerification
@onready var email: TextEdit = %Email
@onready var validation_label: Label = %ValidationLabel

func _on_submit_button_pressed() -> void:
	validation_label.text = ""

	if not username.text:
		validation_label.text = "Username is required"
		return

	if not password.text:
		validation_label.text = "Password is required"
		return

	if enable_verification.button_pressed and not email.text:
		validation_label.text = "Email is required when verification is enabled"
		return

	var res = await Talo.player_auth.register(username.text, password.text, email.text, enable_verification.button_pressed)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				validation_label.text = "Username is already taken"
			TaloAuthError.ErrorCode.INVALID_EMAIL:
				validation_label.text = "Invalid email address"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()

func _on_login_pressed() -> void:
	go_to_login.emit()
