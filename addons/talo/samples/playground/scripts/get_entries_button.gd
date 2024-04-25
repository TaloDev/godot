extends Button

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"
@export var leaderboard_name: String

func _on_pressed() -> void:
	var res = await Talo.leaderboards.get_entries(leaderboard_name, 0)
	var entries = res[0]

	response_label.text = "Received %s entries" % entries.size()
