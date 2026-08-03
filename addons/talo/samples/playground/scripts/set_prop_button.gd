extends Button

@export var prop_name: String
@export var prop_value: String

func _on_pressed() -> void:
	if Talo.identity_check() != OK:
		%ResponseLabel.text = "You need to identify a player first!"
		return

	if prop_name.is_empty() or prop_value.is_empty():
		%ResponseLabel.text = "prop_name or prop_value not set on SetPropButton"
		return

	var result: PlayersAPI.PlayerUpdateResult = await Talo.current_player.set_prop(prop_name, prop_value)
	if not result.rejected_props.is_empty():
		var reasons := result.rejected_props.map(func (rp: TaloRejectedProp): return "[%s] %s" % [rp.key, rp.message])
		%ResponseLabel.text = "Rejected props: %s" % ", ".join(reasons)
		return

	%ResponseLabel.text = "%s saved successfully" % prop_value
