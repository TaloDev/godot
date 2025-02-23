@tool
extends EditorPlugin

func _enter_tree() -> void:
	var talo_manager_path := (get_script() as Script).resource_path.get_base_dir().path_join("talo_manager.gd")

	# Try to create "settings.cfg".
	var talo_manager_script := load(talo_manager_path) as Script
	print(talo_manager_script.get_script_method_list().map(func(d): return d.name).has("create_default_settings"))
	print(talo_manager_script.get("create_default_settings"))
	print(talo_manager_script.get("SETTINGS_PATH"))

	talo_manager_script.create_default_settings(talo_manager_script.SETTINGS_PATH)
	EditorInterface.get_resource_filesystem().update_file(talo_manager_script.SETTINGS_PATH)

	# Add autoload.
	add_autoload_singleton("Talo", talo_manager_path)

func _exit_tree():
	remove_autoload_singleton("Talo")
