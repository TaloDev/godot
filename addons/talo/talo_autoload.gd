@tool
extends EditorPlugin

var export_plugin := TaloExportPlugin.new()

func _enter_tree():
	add_autoload_singleton("Talo", "res://addons/talo/talo_manager.gd")
	add_export_plugin(export_plugin)

func _exit_tree():
	remove_autoload_singleton("Talo")
	remove_export_plugin(export_plugin)
