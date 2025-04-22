class_name TaloChannel extends TaloEntityWithProps

var id: int
var name: String
var owner_alias: TaloPlayerAlias
var total_messages: int
var member_count: int
var private: bool
var created_at: String
var updated_at: String

func _init(data: Dictionary):
	super._init(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

	id = data.id
	name = data.name
	if data.owner:
		owner_alias = TaloPlayerAlias.new(data.owner)
	total_messages = data.totalMessages
	member_count = data.get('memberCount', 0) # TODO: socket messages don't currently send the memberCount
	private = data.private
	created_at = data.createdAt
	updated_at = data.updatedAt
