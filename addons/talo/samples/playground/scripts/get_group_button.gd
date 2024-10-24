extends Button

@export var group_id: String

func _on_pressed() -> void:
	if group_id.is_empty():
		%ResponseLabel.text = "group_id not set on GetGroupButton"
		return

	var group = await Talo.player_groups.get_group(group_id)
	if group != null:
		%ResponseLabel.text = "%s has %s player(s)" % [group.display_name, group.count]
	else:
		%ResponseLabel.text = "Group %s not found" % group_id
