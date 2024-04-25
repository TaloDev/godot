class_name TaloPlayer extends Node

var id: String
var props: Array[TaloProp] = []
var groups: Array[TaloGroup] = []

func _init(data: Dictionary):
	id = data.id
	props.assign(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))
	groups.assign(data.groups.map(func (group): return TaloGroup.new(group.id, group.name)))

func get_prop(key: String, fallback: String) -> String:
	var filtered = props.filter(func (prop: TaloProp): return prop.key == key)
	return fallback if filtered.is_empty() else filtered.front()

func set_prop(key: String, value: String) -> void:
	var filtered = props.filter(func (prop: TaloProp): return prop.key == key)
	if filtered.is_empty():
		props.push_back(TaloProp.new(key, value))
	else:
		filtered.front().value = value
	
	Talo.players.update()

func delete_prop(key: String) -> void:
	props = props.filter(func (prop: TaloProp): return prop.key != key)

func in_player_group(group_id: String) -> bool:
	return not groups.filter(func (group: TaloGroup): return group.id == group_id).is_empty()

func get_serialized_props() -> Array:
	return props \
		.filter(func (prop: TaloProp): return not prop.key.begins_with("META")) \
		.map(func (prop: TaloProp): return prop.to_dictionary())
