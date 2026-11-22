extends GdUnitTestSuite

const BROADCAST_REQ := "v1.player-relationships.broadcast"


class StubSocket extends TaloSocket:
	var sent: Array[Dictionary] = []


	func send(req: String, data: Dictionary = { }) -> int:
		sent.append({ req = req, data = data })
		return OK


var _saved_socket: TaloSocket
var _saved_alias: TaloPlayerAlias

var _socket: StubSocket


func before_test() -> void:
	_saved_socket = Talo.socket
	_saved_alias = Talo.current_alias

	_socket = auto_free(StubSocket.new())
	Talo.socket = _socket
	Talo.current_alias = TaloFixtures.make_alias()


func after_test() -> void:
	Talo.socket = _saved_socket
	Talo.current_alias = _saved_alias


func _single_payload() -> Dictionary:
	assert_int(_socket.sent.size()).is_equal(1)
	assert_str(_socket.sent[0].req).is_equal(BROADCAST_REQ)
	return _socket.sent[0].data


func test_broadcast_without_alias_ids_leaves_alias_ids_out() -> void:
	Talo.player_relationships.broadcast("hello")

	var data := _single_payload()
	assert_bool(data.has("aliasIds")).is_false()
	assert_str(data.message).is_equal("hello")


func test_broadcast_with_empty_alias_ids_targets_nobody() -> void:
	Talo.player_relationships.broadcast_to("hello", PackedInt32Array())

	var data := _single_payload()
	assert_bool(data.has("aliasIds")).is_true()
	var alias_ids: PackedInt32Array = data.aliasIds
	assert_bool(alias_ids.is_empty()).is_true()


func test_broadcast_with_alias_ids_targets_them() -> void:
	Talo.player_relationships.broadcast_to("hello", PackedInt32Array([1, 2]))

	var data := _single_payload()
	var alias_ids: PackedInt32Array = data.aliasIds
	assert_array(alias_ids).contains_exactly([1, 2])
