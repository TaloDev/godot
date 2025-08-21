extends CharacterBody2D

const _username_file_path = "res://talo_save_username.txt"

var destination := position

func _ready() -> void:
	Talo.saves.save_unloaded.connect(func (_save): _clear_username())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		destination = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	velocity = position.direction_to(destination) * 200.0
	move_and_slide()

	if position.distance_to(destination) <= 2:
		destination = position

func _clear_username() -> void:
	DirAccess.remove_absolute(_username_file_path)

func get_username() -> String:
	if FileAccess.file_exists(_username_file_path):
		var file := FileAccess.open(_username_file_path, FileAccess.READ)
		var content := file.get_as_text()
		file.close()
		return content
	else:
		var file := FileAccess.open(_username_file_path, FileAccess.WRITE)
		var username := Talo.players.generate_identifier()
		file.store_string(username)
		file.close()
		return username
