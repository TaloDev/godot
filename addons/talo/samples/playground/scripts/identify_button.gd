extends Button

@export var service: String
@export var identifier: String

func _on_pressed():
	Talo.players.identify(service, identifier)
