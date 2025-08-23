extends Button

@export var group_id: String

func _on_pressed() -> void:
	if group_id.is_empty():
		%ResponseLabel.text = "group_id not set on GetGroupButton"
		return

	var group_page := await Talo.player_groups.get_group(group_id)
	if group_page.group != null:
		%ResponseLabel.text = "%s has %s player(s)" % [group_page.group.name, group_page.count]
	else:
		%ResponseLabel.text = "Group %s not found" % group_id
