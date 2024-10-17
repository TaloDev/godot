extends Label

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)

func _on_identified(_player: TaloPlayer) -> void:
	text = "Played identified"
