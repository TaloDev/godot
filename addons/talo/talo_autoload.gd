@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("Talo", "res://addons/talo/talo_manager.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Talo")
