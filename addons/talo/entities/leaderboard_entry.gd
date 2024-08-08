class_name TaloLeaderboardEntry extends Node

var id: int
var position: int
var score: float
var player_alias: TaloPlayerAlias
var created_at: String
var updated_at: String

func _init(data: Dictionary):
  id = data.id
  position = data.position
  score = data.score
  player_alias = TaloPlayerAlias.new(data.playerAlias)
  created_at = data.createdAt
  updated_at = data.updatedAt
