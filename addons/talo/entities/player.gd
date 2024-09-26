class_name TaloPlayer extends TaloEntityWithProps

var id: String
var groups: Array[TaloGroup] = []

func _init(data: Dictionary):
  super._init(data.props.map(func (prop): return TaloProp.new(prop.key, prop.value)))

  id = data.id
  groups.assign(data.groups.map(func (group): return TaloGroup.new(group.id, group.name)))

func set_prop(key: String, value: String, update: bool = true) -> void:
  super.set_prop(key, value)
  if update:
    Talo.players.update()

func delete_prop(key: String, update: bool = true) -> void:
  super.delete_prop(key)
  if update:
    Talo.players.update()

func is_in_talo_group_id(group_id: String) -> bool:
  return not groups.filter(func (group: TaloGroup): return group.id == group_id).is_empty()

func is_in_talo_group_name(group_name: String) -> bool:
  return not groups.filter(func (group: TaloGroup): return group.name == group_name).is_empty()
