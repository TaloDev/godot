@tool
extends EditorPlugin

func _enter_tree():
	for setting in TaloSettings.Settings.values():
		TaloSettings.add_setting(setting, TaloSettings.DEFAULT[setting])
		print(setting)

	add_autoload_singleton("Talo", "res://addons/talo/talo_manager.gd")

func _exit_tree():
	remove_autoload_singleton("Talo")
