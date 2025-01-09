class_name TaloSocket extends Node
## An interface for communicating with the Talo Socket server.
##
## Sockets are used to provide interactivity to your game. It is highly recommended to use the Talo APIs instead of the socket directly.
##
## @tutorial: https://docs.trytalo.com/docs/godot/socket

static var default_socket_url = "wss://api.trytalo.com"

var _socket = WebSocketPeer.new()
var _temp_socket_token = ""
var _socket_authenticated = false
var _identified = false

## Emitted when a message is received from the Talo Socket server. Not recommended for direct use. See the Talo docs for a list of responses and message structures.
signal message_received(res: String, message: Dictionary)

## Emitted when the connection to the Talo Socket server is closed. The code and reason are provided.
signal connection_closed(code: int, reason: String)

func _ready() -> void:
	message_received.connect(_on_message_received)

func _identify_player() -> void:
	if not _socket_authenticated:
		return

	var payload = {
		playerAliasId = Talo.current_alias.id,
		socketToken = _temp_socket_token
	}

	var session_token = Talo.player_auth.session_manager.get_token()
	if not session_token.is_empty():
		payload.sessionToken = session_token

	send("v1.players.identify", payload)

func _get_socket_url(ticket: String) -> String:
	var url = Talo.settings.get_value("", "socket_url", default_socket_url)
	return "%s/?ticket=%s" % [url, ticket]

## Open the connection to the Talo Socket server. A new ticket is created to authenticate the connection.
func open_connection():
	var ticket = await Talo.socket_tickets.create_ticket()

	var err = _socket.connect_to_url(_get_socket_url(ticket))
	if err != OK:
		print_rich("[color=yellow]Warning: Failed connecting to the Talo Socket: %s[/color]" % err)

func _on_message_received(res: String, data: Dictionary) -> void:
	if Talo.settings.get_value("logging", "responses", false):
		print_rich("[color=aqua]<-- %s %s[/color]" % [res, data])

	match res:
		"v1.connected":
			_socket_authenticated = true
			if not _identified and not _temp_socket_token.is_empty():
				_identify_player()
		"v1.players.identify.success":
			_identified = true
			_temp_socket_token = ""

## A socket token is created for a player alias each time they are identified. This must be sent in order to validate the current socket session.
func set_socket_token(token: String) -> void:
	_temp_socket_token = token
	if not _identified and _socket_authenticated:
		_identify_player()

## Send a message to the Talo Socket server. Not recommended for direct use. See the Talo docs for available requests and message structures.
func send(req: String, data: Dictionary = {}) -> int:
	if Talo.settings.get_value("logging", "requests", false):
		print_rich("[color=orange]--> %s %s[/color]" % [req, data])

	return _socket.send_text(JSON.stringify({
		req = req,
		data = data 
	}))

func _get_json() -> String:
	var pkt = _socket.get_packet()
	return pkt.get_string_from_utf8()

func _emit_message(message: String) -> void:
	var json = JSON.new()
	json.parse(message)

	var res = json.get_data().res
	var data = json.get_data().data
	message_received.emit(res, data)

## Close the connection to the Talo Socket server.
func close_connection(code: int = 1000, reason: String = "") -> void:
	_socket.close(code, reason)

func _reset_socket() -> void:
	connection_closed.emit(_socket.get_close_code(), _socket.get_close_reason())
	_socket = WebSocketPeer.new()
	_socket_authenticated = false
	_identified = false

func _poll() -> void:
	if _socket.get_ready_state() != _socket.STATE_CLOSED:
		_socket.poll()
	elif _socket.get_ready_state() == _socket.STATE_CLOSED and _socket_authenticated:
		_reset_socket()

	while _socket.get_ready_state() == _socket.STATE_OPEN and _socket.get_available_packet_count() > 0:
		var message = _get_json()
		_emit_message(message)

func _process(_delta: float) -> void:
	_poll()
