extends Node2D

@export var prop_key: String

@onready var prop_key_line_edit: LineEdit = %PropKey
@onready var prop_value_line_edit: LineEdit = %PropValue
@onready var prop_live_value_label: Label = %PropLiveValueLabel
@onready var prop_updated_label: Label = %PropUpdatedLabel

var demo_channel: TaloChannel

func _ready() -> void:
	Talo.channels.channel_storage_props_updated.connect(_on_channel_props_updated)
	Talo.channels.channel_storage_props_failed_to_set.connect(_on_channel_storage_props_failed_to_set)

	prop_live_value_label.text = "Set a prop to see live updates"
	prop_updated_label.text = "No prop key set"
	await Talo.players.identify("temp_username", Talo.players.generate_identifier())

	var get_options := Talo.channels.GetChannelsOptions.new()
	get_options.prop_key = "channel-storage-demo"

	var res := await Talo.channels.get_channels(get_options)
	if res.channels.size() > 0:
		demo_channel = res.channels[0]
	else:
		var create_options := Talo.channels.CreateChannelOptions.new()
		create_options.name = "Channel Storage Demo"
		create_options.props = {
			"channel-storage-demo": "true"
		}
		demo_channel = await Talo.channels.create(create_options)

	await Talo.channels.join(demo_channel.id)

	if not prop_key.is_empty():
		prop_key_line_edit.text = prop_key
		var existing_prop := await Talo.channels.get_storage_prop(demo_channel.id, prop_key)
		if existing_prop:
			prop_value_line_edit.text = existing_prop.value
			_on_channel_props_updated(demo_channel, [existing_prop], [])

func _on_channel_props_updated(channel: TaloChannel, upserted_props: Array[TaloChannelStorageProp], deleted_props: Array[TaloChannelStorageProp]) -> void:
	if channel.id != demo_channel.id:
		return

	for prop in upserted_props:
		if prop.key == prop_key_line_edit.text:
			prop_live_value_label.text = "%s live value is: %s" % [prop.key, prop.value]
			prop_updated_label.text = "%s was last updated by %s at %s." % [
				prop.key,
				"you" if prop.last_updated_by_alias.id == Talo.current_alias.id else prop.last_updated_by_alias.identifier,
				prop.updated_at
			]

	for prop in deleted_props:
		if prop.key == prop_key_line_edit.text:
			prop_live_value_label.text = "%s live value is: (deleted)" % prop.key
			prop_updated_label.text = "%s was deleted by %s at %s." % [
				prop.key,
				"you" if prop.last_updated_by_alias.id == Talo.current_alias.id else prop.last_updated_by_alias.identifier,
				prop.updated_at
			]

func _on_channel_storage_props_failed_to_set(channel: TaloChannel, failed_props: Array[TaloChannelStoragePropError]):
	for prop in failed_props:
		print("%s: %s" % [prop.key, prop.error])

func _on_upsert_prop_button_pressed() -> void:
	if prop_key_line_edit.text.is_empty():
		prop_updated_label.text = "No prop key set"
		return
	if prop_value_line_edit.text.is_empty():
		prop_updated_label.text = "No prop value set"
		return

	await Talo.channels.set_storage_props(demo_channel.id, {
		prop_key_line_edit.text: prop_value_line_edit.text
	})

func _on_delete_prop_button_pressed() -> void:
	if prop_key_line_edit.text.is_empty():
		prop_updated_label.text = "No prop key set"
		return
	if prop_value_line_edit.text.is_empty():
		prop_updated_label.text = "No prop value set"
		return

	await Talo.channels.set_storage_props(demo_channel.id, {
		prop_key_line_edit.text: null
	})
