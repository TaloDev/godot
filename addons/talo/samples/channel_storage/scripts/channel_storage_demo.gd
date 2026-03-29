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
		if _is_array_key(prop_key):
			var existing_props := await Talo.channels.get_storage_prop_array(demo_channel.id, prop_key)
			if not existing_props.is_empty():
				prop_value_line_edit.text = _join_prop_values(existing_props)
				_on_channel_props_updated(demo_channel, existing_props, [])
		else:
			var existing_prop := await Talo.channels.get_storage_prop(demo_channel.id, prop_key)
			if existing_prop:
				prop_value_line_edit.text = existing_prop.value
				_on_channel_props_updated(demo_channel, [existing_prop], [])

func _is_array_key(key: String) -> bool:
	return key.ends_with("[]")

func _join_prop_values(props: Array[TaloChannelStorageProp]) -> String:
	return ", ".join(props.map(func (p: TaloChannelStorageProp): return p.value))

func _on_channel_props_updated(channel: TaloChannel, upserted_props: Array[TaloChannelStorageProp], deleted_props: Array[TaloChannelStorageProp]) -> void:
	if channel.id != demo_channel.id:
		return

	var current_key := prop_key_line_edit.text
	var is_array := _is_array_key(current_key)

	var matching_upserted := upserted_props.filter(func (p: TaloChannelStorageProp): return p.key == current_key)
	if not matching_upserted.is_empty():
		var last_prop: TaloChannelStorageProp = matching_upserted.back()
		if is_array:
			prop_live_value_label.text = "%s live values are: [%s]" % [current_key, _join_prop_values(matching_upserted)]
		else:
			prop_live_value_label.text = "%s live value is: %s" % [current_key, last_prop.value]

		prop_updated_label.text = "%s was last updated by %s at %s." % [
			current_key,
			"you" if last_prop.last_updated_by_alias.id == Talo.current_alias.id else last_prop.last_updated_by_alias.identifier,
			last_prop.updated_at
		]

	var matching_deleted := deleted_props.filter(func (p: TaloChannelStorageProp): return p.key == current_key)
	if not matching_deleted.is_empty():
		var last_prop: TaloChannelStorageProp = matching_deleted.back()
		if is_array:
			var remaining := await Talo.channels.get_storage_prop_array(demo_channel.id, current_key)
			if remaining.is_empty():
				prop_live_value_label.text = "%s live values are: (deleted)" % current_key
			else:
				prop_live_value_label.text = "%s live values are: [%s]" % [current_key, _join_prop_values(remaining)]
		else:
			prop_live_value_label.text = "%s live value is: (deleted)" % current_key

		prop_updated_label.text = "%s was deleted by %s at %s." % [
			current_key,
			"you" if last_prop.last_updated_by_alias.id == Talo.current_alias.id else last_prop.last_updated_by_alias.identifier,
			last_prop.updated_at
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

	var key := prop_key_line_edit.text
	if _is_array_key(key):
		var entity := TaloEntityWithProps.new()

		# split the input by commas and trim whitespace
		var items := prop_value_line_edit.text.split(",")
		for item in items:
			entity.insert_into_prop_array(key, item.strip_edges())

		var prop_array := entity.find_props_by_key(key)
		await Talo.channels.set_storage_props(demo_channel.id, TaloPropUtils.props_to_dictionary(prop_array))
	else:
		await Talo.channels.set_storage_props(demo_channel.id, {
			key: prop_value_line_edit.text
		})

func _on_delete_prop_button_pressed() -> void:
	if prop_key_line_edit.text.is_empty():
		prop_updated_label.text = "No prop key set"
		return

	await Talo.channels.set_storage_props(demo_channel.id, {
		prop_key_line_edit.text: null
	})
