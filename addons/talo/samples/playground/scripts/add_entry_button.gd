extends Button

@onready var response_label: Label = $"/root/Playground/UI/MarginContainer/ResponseLabel"
@export var leaderboard_name: String

func _on_pressed() -> void:
	var score = RandomNumberGenerator.new().randi_range(1, 50)
	var res = await Talo.leaderboards.add_entry(leaderboard_name, score)

	if res.size() > 0:
		response_label.text = "Added score: %s, new high score: %s" % [score, res[1]]
