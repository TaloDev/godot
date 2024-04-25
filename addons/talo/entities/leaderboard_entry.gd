class_name TaloLeaderboardEntry extends Node

var id: int
var position: int
var score: float
var player_alias: TaloPlayerAlias
var updated_at: String

func _init(data: Dictionary):
  id = data.id
  position = data.position
  score = data.score
  player_alias = TaloPlayerAlias.new(data.playerAlias)
  updated_at = data.updatedAt
