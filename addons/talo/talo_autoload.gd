@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Talo", "res://addons/talo/talo_manager.gd")

func _exit_tree():
	remove_autoload_singleton("Talo")
