class_name TaloLeaderboardEntry extends TaloEntityWithProps

enum LeaderboardSortMode {
	ASC,
	DESC
}

var id: int
var position: int
var score: float
var player_alias: TaloPlayerAlias
var leaderboard_name: String
var leaderboard_internal_name: String
var leaderboard_sort_mode: LeaderboardSortMode
var created_at: String
var updated_at: String
var deleted_at: String

func _init(data: Dictionary):
	super._init(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

	id = data.id
	position = data.position
	score = data.score
	player_alias = TaloPlayerAlias.new(data.playerAlias)

	leaderboard_name = data.leaderboardName
	leaderboard_internal_name = data.leaderboardInternalName
	leaderboard_sort_mode = LeaderboardSortMode.ASC if data.leaderboardSortMode.to_lower() == 'asc' else LeaderboardSortMode.DESC

	created_at = data.createdAt
	updated_at = data.updatedAt
	if data.deletedAt:
		deleted_at = data.deletedAt
