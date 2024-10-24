extends Node2D

signal go_to_change_password
signal go_to_change_email
signal go_to_delete
signal logout_success

@onready var username: Label = %Username

func _ready() -> void:
	Talo.players.identified.connect(_on_player_identified)

func _on_player_identified(player: TaloPlayer) -> void:
	username.text = "What would you like to do,\n%s?" % Talo.current_alias.identifier

func _on_change_password_pressed() -> void:
	go_to_change_password.emit()

func _on_change_email_pressed() -> void:
	go_to_change_email.emit()

func _on_logout_pressed() -> void:
	await Talo.player_auth.logout()
	logout_success.emit()

func _on_delete_pressed() -> void:
	go_to_delete.emit()
