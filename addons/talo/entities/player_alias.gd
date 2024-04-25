class_name TaloPlayerAlias extends Node

var id: int
var service: String
var identifier: String
var player: TaloPlayer

func _init(data: Dictionary):
	id = data.id
	service = data.service
	identifier = data.identifier
	player = TaloPlayer.new(data.player)
