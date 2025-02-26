extends Node2D


const SPEED = 100.0


var _rpc_test_btn :Button:
	get:
		return %RpcTestButton


func _ready() -> void:
	_rpc_test_btn.disabled = not is_multiplayer_authority()
	_rpc_test_btn.pressed.connect(_on_rpc_test_btn_pressed)

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var dir := Input.get_vector(&"ui_left", &"ui_right", &"ui_up", &"ui_down")
	if dir.is_zero_approx():
		return

	translate(dir * SPEED * delta)

func setup(peer_id: int) -> void:
	set_multiplayer_authority(peer_id)
	%NameLabel.text = str(peer_id)
	if is_inside_tree():
		_rpc_test_btn.disabled = not is_multiplayer_authority()

@rpc("authority", "call_local", "reliable", 1)
func _rpc_test(text: String) -> void:
	_rpc_test_btn.text = str(text)


func _on_rpc_test_btn_pressed() -> void:
	_rpc_test.rpc("RpcTestButton: %s" % randi())
