@tool
class_name TaloExportPlugin extends EditorExportPlugin


func _get_name() -> String:
	return "talo"


func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var cfg_bytes: PackedByteArray = FileAccess.get_file_as_bytes(TaloSettings.settings_path)
	add_file(TaloSettings.settings_path, cfg_bytes, false)
