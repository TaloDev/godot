@tool
extends EditorPlugin

func _enter_tree():
	for setting in TaloSettings.Settings.values():
		TaloSettings.add_setting(setting, TaloSettings.DEFAULT[setting])

	# For compatibility with older versions of the plugin,
	# we need to migrate old settings to ProjectSettings.
	TaloSettings.migrate_old_settings()

	add_autoload_singleton("Talo", "res://addons/talo/talo_manager.gd")

func _exit_tree():
	remove_autoload_singleton("Talo")
