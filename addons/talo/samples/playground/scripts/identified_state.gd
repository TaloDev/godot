extends ColorRect

var _initial_color := color

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)
	Talo.players.identity_cleared.connect(_on_identity_cleared)

func _on_identified(_player: TaloPlayer) -> void:
	color = Color(120.0 / 255.0, 230.0 / 255.0, 160.0 / 255.0)

func _on_identity_cleared() -> void:
	color = _initial_color
