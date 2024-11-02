class_name TaloPlayerAlias extends Node

var id: int
var service: String
var identifier: String
var player: TaloPlayer
var last_seen_at: String
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	service = data.service
	identifier = data.identifier
	player = TaloPlayer.new(data.player)
	last_seen_at = data.lastSeenAt
	created_at = data.createdAt
	updated_at = data.updatedAt
