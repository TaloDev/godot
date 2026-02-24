extends Node2D

signal identifier_change_success
signal go_to_game

@onready var password: TextEdit = %Password
@onready var new_identifier: TextEdit = %NewIdentifier
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not password.text:
		validation_label.text = "Current password is required"
		return

	if not new_identifier.text:
		validation_label.text = "New identifier is required"
		return

	var res := await Talo.player_auth.change_identifier(password.text, new_identifier.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Current password is incorrect"
			TaloAuthError.ErrorCode.NEW_IDENTIFIER_MATCHES_CURRENT_IDENTIFIER:
				validation_label.text = "New identifier must be different from the current identifier"
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				validation_label.text = "Identifier is already taken"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
	else:
		identifier_change_success.emit()

func _on_cancel_pressed() -> void:
	go_to_game.emit()
