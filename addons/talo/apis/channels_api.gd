class_name ChannelsAPI extends TaloAPI
## An interface for communicating with the Talo Channels API.
##
## This API is used to send messages between players who are subscribed to channels.
##
## @tutorial: https://docs.trytalo.com/docs/godot/channels

## Emitted when a message is received from a channel.
signal message_received(channel: TaloChannel, player_alias: TaloPlayerAlias, message: String)
## Emitted when a player is joined to a channel.
signal player_joined(channel: TaloChannel, player_alias: TaloPlayerAlias)
## Emitted when a player is left from a channel.
signal player_left(channel: TaloChannel, player_alias: TaloPlayerAlias, reason: ChannelLeavingReason)
## Emitted when a channel's ownership transferred.
signal channel_ownership_transferred(channel: TaloChannel, new_owner_player_alias: TaloPlayerAlias)
## Emitted when a channel is deleted.
signal channel_deleted(channel: TaloChannel)
## Emitted when a channel is updated.
signal channel_updated(channel: TaloChannel, changed_properties: Array[String])
## Emitted when channel storage props are updated or deleted.
signal channel_storage_props_updated(channel: TaloChannel, upserted_props: Array[TaloChannelStorageProp], deleted_props: Array[TaloChannelStorageProp])
## Emitted when one or more storage props were not successfully set.
signal channel_storage_props_failed_to_set(channel: TaloChannel, failed_props: Array[TaloChannelStoragePropError])

var _storage_manager := TaloChannelStorageManager.new()

func _ready() -> void:
	await Talo.init_completed
	Talo.socket.message_received.connect(_on_message_received)
	channel_storage_props_updated.connect(_storage_manager.on_props_updated)

func _on_message_received(res: String, data: Dictionary) -> void:
	match res:
		"v1.channels.message":
			message_received.emit(TaloChannel.new(data.channel), TaloPlayerAlias.new(data.playerAlias), data.message)
		"v1.channels.player-joined":
			player_joined.emit(TaloChannel.new(data.channel), TaloPlayerAlias.new(data.playerAlias))
		"v1.channels.player-left":
			player_left.emit(TaloChannel.new(data.channel), TaloPlayerAlias.new(data.playerAlias), data.meta.reason)
		"v1.channels.ownership-transferred":
			channel_ownership_transferred.emit(TaloChannel.new(data.channel), TaloPlayerAlias.new(data.newOwner))
		"v1.channels.deleted":
			channel_deleted.emit(TaloChannel.new(data.channel))
		"v1.channels.updated":
			var changed_properties: Array[String] = []
			changed_properties.assign(data.changedProperties)
			channel_updated.emit(TaloChannel.new(data.channel), changed_properties)
		"v1.channels.storage.updated":
			var upserted_props: Array[TaloChannelStorageProp] = []
			upserted_props.assign(data.upsertedProps.map(func (prop: Dictionary): return TaloChannelStorageProp.new(prop)))
			var deleted_props: Array[TaloChannelStorageProp] = []
			deleted_props.assign(data.deletedProps.map(func (prop: Dictionary): return TaloChannelStorageProp.new(prop)))
			channel_storage_props_updated.emit(TaloChannel.new(data.channel), upserted_props, deleted_props)

## Get a channel by its ID.
func find(channel_id: int) -> TaloChannel:
	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s" % channel_id)

	match res.status:
		200:
			return TaloChannel.new(res.body.channel)
		_:
			return null

## Get a list of channels that players can join.
func get_channels(options: GetChannelsOptions = GetChannelsOptions.new()) -> ChannelPage:
	var url := "?page=%s"
	var url_data := [options.page]

	if options.prop_key != "":
		url += "&propKey=%s"
		url_data.append(options.prop_key)

		if options.prop_value != "":
			url += "&propValue=%s"
			url_data.append(options.prop_value)

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var channels: Array[TaloChannel] = []
			channels.assign(res.body.channels.map(func (channel: Dictionary): return TaloChannel.new(channel)))
			return ChannelPage.new(channels, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

## Get a list of channels that the current player is subscribed to.
func get_subscribed_channels(options: GetSubscribedChannelsOptions = GetSubscribedChannelsOptions.new()) -> Array[TaloChannel]:
	if Talo.identity_check() != OK:
		return []

	var url := "/subscriptions"
	var url_data := []

	if options.prop_key != "":
		url += "?propKey=%s"
		url_data.append(options.prop_key)

		if options.prop_value != "":
			url += "&propValue=%s"
			url_data.append(options.prop_value)

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var channels: Array[TaloChannel] = []
			channels.assign(res.body.channels.map(func (channel: Dictionary): return TaloChannel.new(channel)))
			return channels
		_:
			return []

## Create a new channel. The player who creates this channel will automatically become the owner. If auto cleanup is enabled, the channel will be deleted when the owner or the last member leaves. Private channels can only be joined by players who have been invited to the channel. Channels with temporary membership will remove players at the end of their session.
func create(options: CreateChannelOptions = CreateChannelOptions.new()) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var props_to_send := options.props \
		.keys() \
		.map(func (key: String): return { key = key, value = str(options.props[key]) })

	var res := await client.make_request(HTTPClient.METHOD_POST, "", {
		name = options.name,
		autoCleanup = options.auto_cleanup,
		props = props_to_send,
		private = options.private,
		temporaryMembership = options.temporary_membership
	})

	match res.status:
		200:
			return TaloChannel.new(res.body.channel)
		_:
			return null

## Join an existing channel.
func join(channel_id: int) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var res := await client.make_request(HTTPClient.METHOD_POST, "/%s/join" % channel_id)

	match res.status:
		200:
			return TaloChannel.new(res.body.channel)
		_:
			return null

## Leave a channel.
func leave(channel_id: int) -> void:
	if Talo.identity_check() != OK:
		return

	await client.make_request(HTTPClient.METHOD_POST, "/%s/leave" % channel_id)

## Update a channel. This will only work if the current player is the owner of the channel.
func update(channel_id: int, name: String = "", new_owner_alias_id: int = -1, props: Dictionary[String, Variant] = {}) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var data := {}
	if not name.is_empty():
		data.name = name
	if new_owner_alias_id != -1:
		data.ownerAliasId = new_owner_alias_id
	if props.size() > 0:
		data.props = TaloPropUtils.dictionary_to_array(props)

	var res := await client.make_request(HTTPClient.METHOD_PUT, "/%s" % channel_id, data)

	match res.status:
		200:
			return TaloChannel.new(res.body.channel)
		403:
			push_error("Player does not have permissions to update channel %s." % channel_id)
			return null
		_:
			return null

## Delete a channel. This will only work if the current player is the owner of the channel.
func delete(channel_id: int) -> void:
	if Talo.identity_check() != OK:
		return

	var res := await client.make_request(HTTPClient.METHOD_DELETE, "/%s" % channel_id)

	match res.status:
		403:
			push_error("Player does not have permissions to delete channel %s." % channel_id)

## Send a message to a channel.
func send_message(channel_id: int, message: String) -> void:
	if Talo.identity_check() != OK:
		return

	Talo.socket.send("v1.channels.message", {
		channel = {
			id = channel_id
		},
		message = message
	})

## Invite a player to a channel. The invitee will automatically join the channel. This will only work if the current player is the owner of the channel.
func invite(channel_id: int, player_alias_id: int) -> void:
	if Talo.identity_check() != OK:
		return

	var res = await client.make_request(HTTPClient.METHOD_POST, "/%s/invite" % channel_id, {
		inviteeAliasId = player_alias_id
	})

	match res.status:
		403:
			push_error("Player does not have permissions to invite players to channel %s." % channel_id)

## Get the members of a channel.
func get_members(channel_id: int, options := GetMembersOptions.new()) -> MembersPage:
	if Talo.identity_check() != OK:
		return null

	var url := "/%s/members?page=%s"
	var url_data := [channel_id, options.page]

	if options.player_id != "":
		url += "&playerId=%s"
		url_data.append(options.player_id)

	if options.alias_id != -1:
		url += "&aliasId=%s"
		url_data.append(options.alias_id)

	if options.identifier != "":
		url += "&identifier=%s"
		url_data.append(options.identifier)

	if options.prop_key != "":
		url += "&propKey=%s"
		url_data.append(options.prop_key)

		if options.prop_value != "":
			url += "&propValue=%s"
			url_data.append(options.prop_value)

	if options.player_group_id != "":
		url += "&playerGroupId=%s"
		url_data.append(options.player_group_id)

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var members: Array[TaloPlayerAlias] = []
			members.assign(res.body.members.map(func (member: Dictionary): return TaloPlayerAlias.new(member)))
			return MembersPage.new(members, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

## Get a storage prop for a channel. Optionally, ensure the latest version of the prop is returned.
func get_storage_prop(channel_id: int, prop_key: String, bust_cache: bool = false) -> TaloChannelStorageProp:
	if Talo.identity_check() != OK:
		return null

	if not bust_cache:
		return await _storage_manager.get_prop(channel_id, prop_key)

	var res := await client.make_request(HTTPClient.METHOD_GET, "/%s/storage?propKey=%s" % [channel_id, prop_key])

	match res.status:
		200:
			if not res.body.prop:
				return null

			var prop := TaloChannelStorageProp.new(res.body.prop)
			_storage_manager.upsert_prop(channel_id, prop)
			return prop
		_:
			return null

## Get many storage props for a channel. Optionally, ensure the latest versions of the props are returned.
func list_storage_props(channel_id: int, prop_keys: Array[String], bust_cache: bool = false) -> Array[TaloChannelStorageProp]:
	if Talo.identity_check() != OK:
		return []

	if not bust_cache:
		return await _storage_manager.list_props(channel_id, prop_keys)

	var url := "/%s/storage/list" % channel_id
	if prop_keys.size() > 0:
		url += "?" + ("&".join(prop_keys.map(func(key): return "propKeys=%s" % key)))
	var res := await client.make_request(HTTPClient.METHOD_GET, url)

	match res.status:
		200:
			var props: Array[TaloChannelStorageProp] = []
			for prop_data in res.body.props:
				var prop := TaloChannelStorageProp.new(prop_data)
				_storage_manager.upsert_prop(channel_id, prop)
				props.append(prop)
			return props
		_:
			return []

## Set storage props for a channel.
func set_storage_props(channel_id: int, props: Dictionary[String, Variant]) -> void:
	if Talo.identity_check() != OK:
		return

	var res := await client.make_request(HTTPClient.METHOD_PUT, "/%s/storage" % channel_id, {
		props = TaloPropUtils.dictionary_to_array(props)
	})

	match res.status:
		200:
			if res.body.failedProps.size() > 0:
				var failed_props: Array[TaloChannelStoragePropError] = []
				failed_props.assign(res.body.failedProps.map(
					func (prop: Dictionary): return TaloChannelStoragePropError.new(prop.key, prop.error))
				)
				channel_storage_props_failed_to_set.emit(TaloChannel.new(res.body.channel), failed_props)

class ChannelPage:
	var channels: Array[TaloChannel]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(channels: Array[TaloChannel], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.channels = channels
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page

class GetChannelsOptions:
	var page: int = 0
	var prop_key: String = ""
	var prop_value: String = ""

class GetSubscribedChannelsOptions:
	var prop_key: String = ""
	var prop_value: String = ""

class CreateChannelOptions:
	var name: String = ""
	var auto_cleanup: bool = false
	var props: Dictionary[String, String] = {}
	var private: bool = false
	var temporary_membership: bool = false

enum ChannelLeavingReason {
	DEFAULT,
	TEMPORARY_MEMBERSHIP
}

class GetMembersOptions:
	var page: int = 0
	var player_id: String = ""
	var alias_id: int = -1
	var identifier: String = ""
	var prop_key: String = ""
	var prop_value: String = ""
	var player_group_id: String = ""

class MembersPage:
	var members: Array[TaloPlayerAlias]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(members: Array[TaloPlayerAlias], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.members = members
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page
