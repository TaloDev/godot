class_name TaloLeaderboardEntry extends TaloEntityWithProps

var id: int
var position: int
var score: float
var player_alias: TaloPlayerAlias
var created_at: String
var updated_at: String
var deleted_at: String

func _init(data: Dictionary):
	super._init(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

	id = data.id
	position = data.position
	score = data.score
	player_alias = TaloPlayerAlias.new(data.playerAlias)
	created_at = data.createdAt
	updated_at = data.updatedAt
	if data.deletedAt:
		deleted_at = data.deletedAt
