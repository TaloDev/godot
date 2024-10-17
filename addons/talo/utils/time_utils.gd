class_name TimeUtils extends Node

static func get_current_time_msec() -> String:
	return Time.get_datetime_string_from_unix_time(int(Time.get_unix_time_from_system()))

static func get_timestamp_msec() -> int:
	return ceil(Time.get_unix_time_from_system()) * 1000
