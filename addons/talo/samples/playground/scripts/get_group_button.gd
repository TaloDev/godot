extends Button

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"
@export var group_id: String = ""

func _on_pressed() -> void:
	if not group_id.is_empty():
		var group = await Talo.player_groups.get_group(group_id)
		if group != null:
			response_label.text = "%s has %s player(s)" % [group.display_name, group.count]
		else:
			print_rich("[color=yellow]Group %s not found[/color]" % [group_id])
	else:
		print_rich("[color=yellow]group_id not set on GetGroupButton[/color]")
