class_name TaloPlayer extends TaloEntityWithProps
## @tutorial: https://docs.trytalo.com/docs/godot/player-props

var id: String
var groups: Array[TaloPlayerGroupStub] = []

func _init(data: Dictionary):
	super._init(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

	id = data.id
	groups.assign(data.groups.map(func (group): return TaloPlayerGroupStub.new(group.id, group.name)))

## Set a property by key and value. Optionally sync the player (default true) with Talo.
func set_prop(key: String, value: String, update: bool = true) -> void:
	super.set_prop(key, value)
	if update:
		await Talo.players.update()

## Delete a property by key. Optionally sync the player (default true) with Talo.
func delete_prop(key: String, update: bool = true) -> void:
	super.delete_prop(key)
	if update:
		await Talo.players.update()

## Check if the player is in a group with the given ID.
func is_in_talo_group_id(group_id: String) -> bool:
	return not groups.filter(func (group: TaloPlayerGroupStub): return group.id == group_id).is_empty()

## Check if the player is in a group with the given name.
func is_in_talo_group_name(group_name: String) -> bool:
	return not groups.filter(func (group: TaloPlayerGroupStub): return group.name == group_name).is_empty()
