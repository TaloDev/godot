extends Node2D

@export var username: String = "username"

func _ready() -> void:
	Talo.players.identified.connect(_on_identified)
	Talo.players.identify("username", username)

func _on_identified(_player: TaloPlayer) -> void:
	var saves = await Talo.saves.get_saves()
	if saves.is_empty():
		await Talo.saves.create_save("save")

	await Talo.saves.choose_save(Talo.saves.all.front())
