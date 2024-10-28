extends Button

@export var service: String = "username"
@export var identifier: String

func _on_pressed():
	if service.is_empty() or identifier.is_empty():
		%ResponseLabel.text = "service or identifier not set on IdentifyButton"
		return

	Talo.players.identify(service, identifier)
