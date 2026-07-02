extends Node2D


@export var services := "username"
@export var multiplayer_channel_name := "test_multiplayer_channel"

var peer := TaloMultiplayerPeer.new()

func _ready() -> void:
	assert(not multiplayer_channel_name.is_empty())
	%IdentifyButton.pressed.connect(_on_identify_btn_pressed)

func _spawn_player(peer_id: int) -> void:
	var player := preload("../player.tscn").instantiate()
	player.name = str(peer_id)
	player.setup(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		var vp_center := get_tree().root.size * 0.5
		var spawn_range := vp_center * 0.4
		var spawn_position := vp_center + Vector2(
			randf_range(-spawn_range.x, spawn_range.x),
			randf_range(-spawn_range.y, spawn_range.y)
		)
		player.position = spawn_position

func _on_identify_btn_pressed() -> void:
	var msg_label := %MessageLabel as Label
	var btn := %IdentifyButton as Button

	btn.disabled = true
	# Identify
	if Talo.identity_check(false) != OK:
		var identifier := (%IdentifierLineEdit.text as String).strip_edges()
		if identifier.is_empty():
			msg_label.text = "Identify failed: identifier is empty."
			btn.disabled = false
			return

		await Talo.players.identify(services, identifier)

	if Talo.identity_check(false) != OK:
		msg_label.text = "Identify failed: please check output for more details if logging is enabled."
		btn.disabled = false
		return


	# Channels
	var channel_id := -1
	# Find exists channel.
	var page := 0
	while true:
		var res := await Talo.channels.get_channels(page)
		if not is_instance_valid(res):
			msg_label.text = "Join channel failed: please check output for more details if logging is enabled."
			btn.disabled = false
			return

		for channel: TaloChannel in res.channels:
			if channel.name == multiplayer_channel_name:
				channel_id = channel.id
				break

		if res.is_last_page:
			# Last page.
			break

		page += 1

	# Create new channel if not exists.
	if channel_id < 0:
		var channel := await Talo.channels.create(multiplayer_channel_name, true)
		if not is_instance_valid(channel):
			msg_label.text = "Join channel failed: please check output for more details if logging is enabled."
			btn.disabled = false
			return

		channel_id = channel.id

	# Join to the channel if need.
	var subscribed_channels := await Talo.channels.get_subscribed_channels()
	if subscribed_channels.all(func(channel: TaloChannel) -> bool: return channel.id != channel_id):
		var joined_channel := await Talo.channels.join(channel_id)
		if not is_instance_valid(joined_channel):
			msg_label.text = "Join channel failed: please check output for more details if logging is enabled."
			btn.disabled = false
			return


	# Join successful, setup TaloMultiplayerPeer
	get_tree().get_multiplayer().multiplayer_peer = peer
	if peer.listen_channel(channel_id) != OK:
		btn.disabled = false
		return

	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)

	%Identify.hide()
	_spawn_player(peer.get_unique_id())

func _on_peer_connected(id: int) -> void:
	_spawn_player(id)

func _on_peer_disconnected(id: int) -> void:
	for node in get_children():
		if node.name != str(id):
			continue
		remove_child(node)
		node.queue_free()
		return
