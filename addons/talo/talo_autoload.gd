@tool
extends EditorPlugin

func _enter_tree() -> void:
	var talo_manager_path := (get_script() as Script).resource_path.get_base_dir().path_join("talo_manager.gd")
	# Try to create "settings.cfg".
	var settings_path := (get_script() as Script).resource_path.get_base_dir().path_join("settings.cfg")
	(load(talo_manager_path) as Script).create_default_settings(settings_path)
	EditorInterface.get_resource_filesystem().update_file(settings_path)

	# Add autoload.
	add_autoload_singleton("Talo", talo_manager_path)

func _exit_tree() -> void:
	remove_autoload_singleton("Talo")
