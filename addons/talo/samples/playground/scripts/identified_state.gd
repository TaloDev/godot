extends ColorRect

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)

func _on_identified(_player: TaloPlayer) -> void:
		color = Color(0.0, 190.0 / 255.0, 130.0 / 255.0)
