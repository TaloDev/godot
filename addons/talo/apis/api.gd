class_name TaloAPI extends Node

var client: TaloClient

func _init(base_path: String):
	client = TaloClient.new(base_path)
	add_child(client)
