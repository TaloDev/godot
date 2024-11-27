class_name TimeUtils extends Node

## Get an ISO 8601 datetime string (YYYY-MM-DDTHH:MM:SS) from the current time.
static func get_current_datetime_string() -> String:
	return Time.get_datetime_string_from_unix_time(int(Time.get_unix_time_from_system()))

## Get the current time in milliseconds.
static func get_timestamp_msec() -> int:
	return ceil(Time.get_unix_time_from_system()) * 1000
