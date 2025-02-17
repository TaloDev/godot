extends Node2D

@export var player_username = ""

var _active_channel_id = -1
var _subscriptions: Array[TaloChannel] = []

func _ready():
	Talo.players.identified.connect(_on_identified)
	Talo.channels.message_received.connect(_on_message_received)
	Talo.player_presence.presence_changed.connect(_on_presence_changed)

	if player_username.is_empty():
		_add_chat_message("[SYSTEM] No player_username set, please set one in the Chat root node")
		return

	Talo.players.identify("username", player_username)

func _on_presence_changed(presence: TaloPlayerPresence, online_changed: bool, custom_status_changed: bool) -> void:
	if online_changed:
		_add_chat_message("[SYSTEM] %s is now %s" % [presence.player_alias.identifier, "online" if presence.online else "offline"])

func _on_identified(player: TaloPlayer) -> void:
	_subscriptions = await Talo.channels.get_subscribed_channels()

	var res = await Talo.channels.get_channels(0)
	var channels = res[0]
	_add_chat_message("[SYSTEM] Found %s channel%s" % [channels.size(), "" if channels.size() == 1 else "s"])
	for channel in channels:
		_add_channel_label(channel.id, channel.display_name)

func _on_message_received(channel: TaloChannel, player_alias: TaloPlayerAlias, message: String) -> void:
	if channel.id == _active_channel_id:
		_add_chat_message("[%s] %s: %s" % [channel.display_name, player_alias.identifier, message])

func _on_add_channel_button_pressed() -> void:
	if %ChannelName.text.is_empty():
		return

	var channel = await Talo.channels.create(%ChannelName.text, true)
	if channel:
		_subscriptions.append(channel)
		_add_channel_label(channel.id, channel.display_name)
		%ChannelName.text = ""

func _add_chat_message(message: String) -> void:
	var chat_message = Label.new()
	chat_message.text = message
	%Messages.add_child(chat_message)

func _is_subscribed_to_channel(id: int) -> bool:
	return _subscriptions.map(func (channel): return channel.id).find(id) != -1

func _add_channel_label(id: int, display_name: String) -> void:
	var button = Button.new()
	button.text = display_name
	button.pressed.connect(func (): _set_active_channel(id, display_name))
	%Channels.add_child(button)

func _set_active_channel(id: int, display_name: String) -> void:
	if _active_channel_id == id:
		return

	if !_is_subscribed_to_channel(id):
		var channel = await Talo.channels.join(id)
		_subscriptions.append(channel)
		_add_chat_message("[SYSTEM] Subscribed to channel %s" % display_name)

	_active_channel_id = id
	_add_chat_message("[SYSTEM] Switched to channel %s" % display_name)

func _on_chat_message_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		return

	if _active_channel_id == -1:
		_add_chat_message("[SYSTEM] No active channel, create one first")
		return

	await Talo.channels.send_message(_active_channel_id, new_text)
	%ChatMessage.text = ""
