@tool
class_name TaloExportPlugin extends EditorExportPlugin


func _get_name() -> String:
	return "talo"


func _export_begin(
	_features: PackedStringArray,
	_is_debug: bool,
	_path: String,
	_flags: int,
) -> void:
	var cfg_bytes: PackedByteArray = FileAccess.get_file_as_bytes(TaloSettings.settings_path)
	add_file(TaloSettings.settings_path, cfg_bytes, false)
