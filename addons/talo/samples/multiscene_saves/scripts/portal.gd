extends Area2D

@export var to_level := ""
@export var spawn_point := Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	body.find_child("Loadable").on_portal_entered(to_level, spawn_point)
