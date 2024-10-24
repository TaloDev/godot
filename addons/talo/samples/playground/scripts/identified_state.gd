extends ColorRect

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)

func _on_identified(_player: TaloPlayer) -> void:
	color = Color(120.0 / 255.0, 230.0 / 255.0, 160.0 / 255.0)
