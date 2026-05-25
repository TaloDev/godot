extends Button

@export var prop_name: String
@export var prop_value: String

func _ready() -> void:
	Talo.players.props_rejected.connect(_on_props_rejected)

func _on_props_rejected(rejected_props: Array[TaloRejectedProp]) -> void:
	var reasons := rejected_props.map(func (rp: TaloRejectedProp): return "[%s] %s" % [rp.key, rp.message])
	%ResponseLabel.text = "Rejected props: %s" % ", ".join(reasons)

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if prop_name.is_empty() or prop_value.is_empty():
		%ResponseLabel.text = "prop_name or prop_value not set on SetPropButton"
		return

	Talo.current_player.set_prop(prop_name, prop_value)
