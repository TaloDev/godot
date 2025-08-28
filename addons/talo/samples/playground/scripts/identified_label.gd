extends Label

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)
	Talo.players.identity_cleared.connect(_on_identity_cleared)

func _on_identified(_player: TaloPlayer) -> void:
	text = "Player identified"

func _on_identity_cleared() -> void:
	text = "Player identity cleared"
