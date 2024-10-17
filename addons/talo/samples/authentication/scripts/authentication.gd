extends Node2D

@onready var login = %Login
@onready var register = %Register
@onready var verify = %Verify
@onready var in_game = %InGame
@onready var change_password = %ChangePassword
@onready var change_email = %ChangeEmail
@onready var forgot_password = %ForgotPassword
@onready var reset_password = %ResetPassword
@onready var delete_account = %DeleteAccount
@onready var all_states = %States

func _ready() -> void:
	_configure_signals()
	_make_state_visible(login)

func _make_state_visible(state: Node2D):
	for child in all_states.get_children():
		child.visible = child == state

func _configure_signals():
	login.verification_required.connect(func (): _make_state_visible(verify))
	login.go_to_forgot_password.connect(func (): _make_state_visible(forgot_password))
	login.go_to_register.connect(func (): _make_state_visible(register))

	register.go_to_login.connect(func (): _make_state_visible(login))

	in_game.go_to_change_password.connect(func (): _make_state_visible(change_password))
	in_game.go_to_change_email.connect(func (): _make_state_visible(change_email))
	in_game.go_to_delete.connect(func (): _make_state_visible(delete_account))
	in_game.logout_success.connect(func (): _make_state_visible(login))

	change_password.password_change_success.connect(func (): _make_state_visible(in_game))
	change_password.go_to_game.connect(func (): _make_state_visible(in_game))

	change_email.email_change_success.connect(func (): _make_state_visible(in_game))
	change_email.go_to_game.connect(func (): _make_state_visible(in_game))

	forgot_password.forgot_password_success.connect(func (): _make_state_visible(reset_password))
	forgot_password.go_to_login.connect(func (): _make_state_visible(login))

	reset_password.password_reset_success.connect(func (): _make_state_visible(login))
	reset_password.go_to_forgot_password.connect(func (): _make_state_visible(forgot_password))

	delete_account.delete_account_success.connect(func (): _make_state_visible(login))
	delete_account.go_to_game.connect(func (): _make_state_visible(in_game))

	Talo.players.identified.connect(func (player): _make_state_visible(in_game))
