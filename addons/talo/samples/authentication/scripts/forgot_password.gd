extends Node2D

signal forgot_password_success
signal go_to_login

@onready var email: TextEdit = %Email
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not email.text:
		validation_label.text = "Email is required"
		return

	if await Talo.player_auth.forgot_password(email.text) == OK:
		forgot_password_success.emit()

func _on_cancel_pressed() -> void:
	go_to_login.emit()
