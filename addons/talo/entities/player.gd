class_name TaloPlayer extends TaloEntityWithProps
## @tutorial: https://docs.trytalo.com/docs/godot/player-props

var id: String
var aliases: Array[TaloPlayerAlias] = []
var groups: Array[TaloPlayerGroupStub] = []

var _offline_data: Dictionary

func _init(data: Dictionary):
	super._init([])
	update_from_raw_data(data)

## Update the player from raw JSON data.
func update_from_raw_data(data: Dictionary) -> void:
	props.assign(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

	id = data.id
	if data.has("aliases"):
		aliases.assign(data.aliases.map(func (alias): return TaloPlayerAlias.new(alias)))
	groups.assign(data.groups.map(func (group): return TaloPlayerGroupStub.new(group.id, group.name)))

	_offline_data = data

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

## Get the offline data for the player.
func get_offline_data() -> Dictionary:
	return _offline_data

## Get the first alias that matches an optional service.
func get_alias(service: String = "") -> TaloPlayerAlias:
	if service == "":
		return null if aliases.is_empty() else aliases[0]
	for alias in aliases:
		if alias.service == service:
			return alias
	return null
