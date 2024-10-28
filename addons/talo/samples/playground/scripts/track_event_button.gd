extends Button

@export var event_name: String
@export var event_props: Dictionary = {
	"prop1": "value1"
}
@export var flush_immediately: bool

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if event_name.is_empty():
		%ResponseLabel.text = "event_name not set on TrackEventButton"
		return

	Talo.events.track(event_name, event_props)
	if flush_immediately:
		await Talo.events.flush()
		%ResponseLabel.text = "Event flushed: %s %s" % [event_name, event_props]
	else:
		%ResponseLabel.text = "Event queued: %s %s" % [event_name, event_props]
