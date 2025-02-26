## Implemented through Talo Channels API.
## All peers are clients, there have not server peer in this implementation.
## Use "listen_channel()" to listen to a talo channel and start behave as a multiplayer peer.
## Note: unique id is equal to TaloAlias.id.
## Limitations:
## - Only support reliable mode.
## - Different transfer channels( not talo channels) has not essential difference.
## - "disconnect_peer()" is not implemented, there have not server peer and not one have ability to kick a talo player from a talo channel.
## - Can't refuse new connections, the reason is similar to previous one.

class_name TaloMultiplayerPeer
extends MultiplayerPeerExtension

const MAGIC_PREFIX := "^TLMP^|"
static var MAX_PACKET_SIZE: int = 1024

const STOP_SENDING_INTERVAL_MSEC := 500

var _connected_peers := PackedInt32Array()
var _talo_channel_id: int = -1
var _incoming_packets: Array[Array] # Each element is an incoming packet, see [enum _PacketField] for more details.
var _target_peer := -1
var _transfer_channel := 0

enum _Event {
	PACKET,
	CONNECT,
	DISCONNECT,
}

# Pack Definition.
enum _PacketField {
	EVENT,
	PEER, # Sender peer of incoming packet. Target peer of sending packet.
	CHANNEL,
	DATA,

	MAX, # Not a file of packet.
}


var _pending_message_queue: PackedStringArray = []
var _sending_enable_tick_msec := -1


## Listen to a joined talo channel and start behave as a multiplayer peer.
func listen_channel(talo_channel_id: int) -> Error:
	assert(talo_channel_id >= 0)

	if _talo_channel_id >= 0:
		push_error("Already listen channel: %s. Please close it first." % _talo_channel_id)
		return ERR_ALREADY_IN_USE

	if Talo.identity_check() != OK:
		return ERR_UNAUTHORIZED

	_talo_channel_id = talo_channel_id
	if _send_packet_message(_Event.CONNECT, 0, 0) != OK:
		push_error("Listen channel failed.")
		_talo_channel_id = -1
		return ERR_CONNECTION_ERROR

	Talo.channels.message_received.connect(_on_channels_message_received)
	Talo.channels.player_left.connect(_on_channels_player_left)
	Talo.channels.channel_deleted.connect(_on_channels_channel_deleted)
	Talo.socket.error_received.connect(_on_socket_error_received)

	if not _connected_peers.has(Talo.current_alias.id):
		_connected_peers.push_back(Talo.current_alias.id)


	return OK

func _make_incoming_packet(event: _Event, sender_peer: int, channel: int, data := PackedByteArray()) -> Array:
	var ret := []
	ret.resize(_PacketField.MAX)
	ret[_PacketField.EVENT] = event
	ret[_PacketField.PEER] = sender_peer
	ret[_PacketField.CHANNEL] = channel
	ret[_PacketField.DATA] = data
	return ret

func _on_channels_message_received(talo_channel: TaloChannel, player_alias: TaloPlayerAlias, message: String) -> void:
	if talo_channel.id != _talo_channel_id:
		# Message is not from listening talo channel.
		return

	if player_alias.id == Talo.current_alias.id:
		# Skip message from self.
		return

	if not message.begins_with(MAGIC_PREFIX):
		# Not packet message.
		return

	if _get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		# Local is not connected.
		return

	for msg in message.split(MAGIC_PREFIX, false):
		# Deserialize
		var packet := msg.trim_prefix(MAGIC_PREFIX).split("|")
		assert(packet.size() in [_PacketField.MAX, _PacketField.MAX - 1])
		var event := packet[_PacketField.EVENT].to_int() as _Event
		var target_peer := packet[_PacketField.PEER].to_int()
		var channel := packet[_PacketField.CHANNEL].to_int()
		var data: PackedByteArray
		if packet.size() == _PacketField.MAX:
			data = Marshalls.base64_to_raw(packet[_PacketField.DATA])
			assert(not data.is_empty())

		var sender_peer := player_alias.id
		match event:
			_Event.PACKET:
				if target_peer != 0 and target_peer != Talo.current_alias.id:
					# Not broadcast and not sent to local peer.
					return

				if not _connected_peers.has(sender_peer):
					# Add to connected list if it is not exists.
					_connected_peers.push_back(sender_peer)
					peer_connected.emit(sender_peer)

				assert(not data.is_empty())
				_incoming_packets.push_back(_make_incoming_packet(event, sender_peer, channel, data))
			_Event.CONNECT:
				if _connected_peers.has(sender_peer):
					return
				_connected_peers.push_back(sender_peer)
				_send_packet_message(_Event.CONNECT, sender_peer, 0) # Send connected peers to the new connected peer.
				peer_connected.emit(sender_peer)
			_Event.DISCONNECT:
				if not _connected_peers.has(sender_peer):
					return
				_connected_peers.remove_at(_connected_peers.find(sender_peer))
				peer_disconnected.emit(sender_peer)

func _on_channels_player_left(talo_channel: TaloChannel, player_alias: TaloPlayerAlias) -> void:
	if talo_channel.id == _talo_channel_id and player_alias.id in _connected_peers:
		_connected_peers.remove_at(_connected_peers.find(player_alias.id))
		peer_disconnected.emit(player_alias.id)
		if player_alias.id == Talo.current_alias.id:
			_close()

func _on_channels_channel_deleted(talo_channel: TaloChannel) -> void:
	while not _connected_peers.is_empty():
		var peer := _connected_peers[-1]
		_connected_peers.remove_at(-1)
		peer_disconnected.emit(peer)
	_close()

func _send_packet_message(event: _Event, target_peer: int, channel: int, data := PackedByteArray()) -> Error:
	if Talo.identity_check() == OK and _talo_channel_id >= 0:
		# Serialize.
		var msg := "%s%s|%s|%s" % [MAGIC_PREFIX, event, target_peer, channel]
		if not data.is_empty():
			msg += "|%s" % Marshalls.raw_to_base64(data)
		_pending_message_queue.push_back(msg)
		return OK
	else:
		return ERR_INVALID_PARAMETER

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_close()

func _close() -> void:
	if _talo_channel_id < 0:
		return

	Talo.channels.message_received.disconnect(_on_channels_message_received)
	Talo.channels.player_left.disconnect(_on_channels_player_left)
	Talo.channels.channel_deleted.disconnect(_on_channels_channel_deleted)
	Talo.socket.error_received.disconnect(_on_socket_error_received)

	if is_instance_valid(Talo.current_player) and _talo_channel_id >= 0:
		_send_packet_message(_Event.PACKET, 0, 0)
	_connected_peers.clear()
	_talo_channel_id = -1

func _disconnect_peer(_peer: int, _force: bool) -> void:
	## Has not ability to disconnect peer.
	pass

func _get_available_packet_count() -> int:
	return _incoming_packets.size()

func _get_connection_status() -> MultiplayerPeer.ConnectionStatus:
	if Talo.identity_check(false) == OK:
		if _talo_channel_id >= 0:
			if _connected_peers.has(Talo.current_alias.id):
				return MultiplayerPeer.CONNECTION_CONNECTED
			else:
				return MultiplayerPeer.CONNECTION_CONNECTING
	return MultiplayerPeer.CONNECTION_CONNECTED

func _get_max_packet_size() -> int:
	return MAX_PACKET_SIZE

func _get_unique_id() -> int:
	if Talo.identity_check() == OK:
		return Talo.current_alias.id
	return -1

func _is_server() -> bool:
	return false

func _is_server_relay_supported() -> bool:
	return false

func _poll() -> void:
	if _pending_message_queue.is_empty() or Time.get_ticks_msec() < _sending_enable_tick_msec:
		return
	if Talo.identity_check() == OK and _talo_channel_id >= 0:
		Talo.channels.send_message(_talo_channel_id, "".join(_pending_message_queue))
		_pending_message_queue.clear()

func _put_packet_script(p_buffer: PackedByteArray) -> Error:
	return _send_packet_message(_Event.PACKET, _target_peer, _transfer_channel, p_buffer)

func _get_packet_script() -> PackedByteArray:
	var packet := _incoming_packets.pop_front()
	assert(not packet[_PacketField.DATA].is_empty())
	return packet[_PacketField.DATA]

func _set_refuse_new_connections(_enable: bool) -> void:
	assert(false, "Unsupported feature.")

func _is_refusing_new_connections() -> bool:
	return false

func _set_target_peer(p_peer: int) -> void:
	_target_peer = p_peer

func _set_transfer_channel(p_channel: int) -> void:
	_transfer_channel = p_channel

func _get_transfer_channel() -> int:
	return _transfer_channel

func _set_transfer_mode(p_mode: MultiplayerPeer.TransferMode) -> void:
	assert(p_mode == MultiplayerPeer.TRANSFER_MODE_RELIABLE, "Only support reliable mode.")

func _get_transfer_mode() -> MultiplayerPeer.TransferMode:
	# Only support reliable mode.
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE

func _get_packet_mode() -> MultiplayerPeer.TransferMode:
	# Only support reliable mode.
	return MultiplayerPeer.TRANSFER_MODE_RELIABLE

func _get_packet_channel() -> int:
	if _incoming_packets.is_empty():
		return 0
	else:
		return _incoming_packets[0][_PacketField.CHANNEL]

func _get_packet_peer() -> int:
	if _incoming_packets.is_empty():
		if Talo.identity_check() == OK:
			return Talo.current_alias.id
		else:
			return -1
	else:
		return _incoming_packets[0][_PacketField.PEER]


# ---
func _on_socket_error_received(err: TaloSocketError) -> void:
	if err.code == TaloSocketError.ErrorCode.RATE_LIMIT_EXCEEDED:
		push_error("Rate limit exceeded. This peer will stop sending messages for a while. Please try to increase the sync intervals.")
		_sending_enable_tick_msec = Time.get_ticks_msec() + STOP_SENDING_INTERVAL_MSEC
