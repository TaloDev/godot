class_name ChannelsAPI extends TaloAPI
## An interface for communicating with the Talo Channels API.
##
## This API is used to send messages between players who are subscribed to channels.
##
## @tutorial: https://docs.trytalo.com/docs/godot/channels

## Emitted when a message is received from a channel.
signal message_received(channel: TaloChannel, player_alias: TaloPlayerAlias, message: String)

func _ready():
	await Talo.init_completed
	Talo.socket.message_received.connect(_on_message_received)

func _on_message_received(res: String, data: Dictionary) -> void:
	if res == "v1.channels.message":
		message_received.emit(TaloChannel.new(data.channel), TaloPlayerAlias.new(data.playerAlias), data.message)

## Get a channel by its ID.
func find(channel_id: int) -> TaloChannel:
	var res = await client.make_request(HTTPClient.METHOD_GET, "/%s" % channel_id)

	match (res.status):
		200:
			return TaloChannel.new(res.body.channel)
		_:
			return null

## Get a list of channels that players can join.
func get_channels(page: int) -> Array:
	var res = await client.make_request(HTTPClient.METHOD_GET, "?page=%s" % page)

	match (res.status):
		200:
			var channels: Array[TaloChannel] = []
			channels.assign(res.body.channels.map(func (channel: Dictionary): return TaloChannel.new(channel)))
			return [channels, res.body.count, res.body.isLastPage]
		_:
			return []

## Get a list of channels that the current player is subscribed to.
func get_subscribed_channels() -> Array[TaloChannel]:
	if Talo.identity_check() != OK:
		return []

	var res = await client.make_request(HTTPClient.METHOD_GET, "/subscriptions")

	match (res.status):
		200:
			var channels: Array[TaloChannel] = []
			channels.assign(res.body.channels.map(func (channel: Dictionary): return TaloChannel.new(channel)))
			return channels
		_:
			return []

## Create a new channel. The player who creates this channel will automatically become the owner. If auto cleanup is enabled, the channel will be deleted when the owner or the last member leaves.
func create(name: String, auto_cleanup: bool = false, props: Dictionary = {}) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var props_to_send = props.keys().map(func (key: String): return { key = key, value = str(props[key]) })

	var res = await client.make_request(HTTPClient.METHOD_POST, "", {
		name = name,
		autoCleanup = auto_cleanup,
		props = props_to_send
	})

	match (res.status):
		200:
			return TaloChannel.new(res.body.channel)
		_:
			return null

## Join an existing channel.
func join(channel_id: int) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var res = await client.make_request(HTTPClient.METHOD_POST, "/%s/join" % channel_id)

	match (res.status):
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
func update(channel_id: int, name: String = "", new_owner_alias_id: int = -1, props: Dictionary = {}) -> TaloChannel:
	if Talo.identity_check() != OK:
		return

	var data = {}
	if not name.is_empty():
		data.name = name
	if new_owner_alias_id != -1:
		data.ownerAliasId = new_owner_alias_id
	if props.size() > 0:
		data.props = props

	var res = await client.make_request(HTTPClient.METHOD_PUT, "/%s" % channel_id, data)

	match (res.status):
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

	var res = await client.make_request(HTTPClient.METHOD_DELETE, "/%s" % channel_id)

	match (res.status):
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
