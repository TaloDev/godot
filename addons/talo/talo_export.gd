@tool
class_name TaloExportPlugin extends EditorExportPlugin

func _get_name() -> String:
	return "talo"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var cfg_bytes : PackedByteArray = FileAccess.get_file_as_bytes("res://addons/talo/settings.cfg")
	add_file("res://addons/talo/settings.cfg", cfg_bytes, false)
