extends Node2D

@onready var code: TextEdit = %Code
@onready var validation_label: Label = %ValidationLabel

func _on_submit_pressed() -> void:
	validation_label.text = ""

	if not code.text:
		validation_label.text = "Verification code is required"
		return

	var res = await Talo.player_auth.verify(code.text)
	if res != OK:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.VERIFICATION_CODE_INVALID:
				validation_label.text = "Verification code is incorrect"
			TaloAuthError.ErrorCode.VERIFICATION_ALIAS_NOT_FOUND:
				validation_label.text = "Verification session is invalid"
			_:
				validation_label.text = Talo.player_auth.last_error.get_string()
