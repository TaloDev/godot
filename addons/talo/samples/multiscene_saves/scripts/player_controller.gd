extends CharacterBody2D

const _USERNAME_FILE_PATH = "res://talo_save_username.txt"

var destination := position


func _ready() -> void:
	Talo.saves.save_unloaded.connect(
		func(_save):
			_clear_username(),
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		destination = get_global_mouse_position()


func _physics_process(_delta: float) -> void:
	velocity = position.direction_to(destination) * 200.0
	move_and_slide()

	if position.distance_to(destination) <= 2:
		destination = position


func _clear_username() -> void:
	DirAccess.remove_absolute(_USERNAME_FILE_PATH)


func get_username() -> String:
	if FileAccess.file_exists(_USERNAME_FILE_PATH):
		var file := FileAccess.open(_USERNAME_FILE_PATH, FileAccess.READ)
		var content := file.get_as_text()
		file.close()
		return content

	var file := FileAccess.open(_USERNAME_FILE_PATH, FileAccess.WRITE)
	var username := Talo.players.generate_identifier()
	file.store_string(username)
	file.close()
	return username
