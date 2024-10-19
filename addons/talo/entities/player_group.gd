class_name TaloPlayerGroup extends Node

var id: String
var display_name: String
var description: String
var rules: Array
var rule_mode: String
var members_visible: bool
var count: int
var members: Array[TaloPlayer]
var updated_at: String

func _init(data: Dictionary):
	id = data.id
	display_name = data.name
	description = data.description
	rules = data.rules
	rule_mode = data.ruleMode
	members_visible = data.membersVisible
	count = data.count
	if data.has("members"):
		members.assign(data.members.map(func (member): return TaloPlayer.new(member)))
	else:
		members = []
	updated_at = data.updatedAt
