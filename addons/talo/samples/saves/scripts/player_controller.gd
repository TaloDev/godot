extends CharacterBody2D

var destination := position

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		destination = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	velocity = position.direction_to(destination) * 200.0
	move_and_slide()

	if position.distance_to(destination) <= 2:
		destination = position
