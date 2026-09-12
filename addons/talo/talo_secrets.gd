class_name TaloSecrets
extends RefCounted

var _config_file: ConfigFile

const SECRETS_PATH := "res://talo_secrets.cfg"

## Your Talo access key, allowing you to connect to the Talo API and access data based on its scopes
var access_key: String:
	get:
		return _config_file.get_value("", "access_key", "")
	set(value):
		_config_file.set_value("", "access_key", value)

## The version of the verification key being used
var verification_key_version: String:
	get:
		return _config_file.get_value("verification", "key_version", "")
	set(value):
		_config_file.set_value("verification", "key_version", value)

## The value for the verification key version
var verification_key_value: String:
	get:
		return _config_file.get_value("verification", "key_value", "")
	set(value):
		_config_file.set_value("verification", "key_value", value)


func _init() -> void:
	_config_file = ConfigFile.new()

	if not FileAccess.file_exists(SECRETS_PATH):
		print_rich("[color=yellow]Warning: %s does not exist; you should create it and add your access key[/color]" % SECRETS_PATH)
	else:
		_config_file.load(SECRETS_PATH)
		if access_key.is_empty() and Talo.is_debug_build():
			print_rich("[color=yellow]Warning: Talo access_key in %s is empty[/color]" % SECRETS_PATH)
