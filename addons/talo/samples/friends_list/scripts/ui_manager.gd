class_name FriendsListUIManager extends RefCounted

var _feed_container: VBoxContainer
var _feed_scroll: ScrollContainer
var _players_list: VBoxContainer
var _subscriptions_list: VBoxContainer
var _pending_requests_list: VBoxContainer
var _outgoing_requests_list: VBoxContainer

func _init(feed: VBoxContainer, feed_scroll: ScrollContainer, players: VBoxContainer, subscriptions: VBoxContainer, pending: VBoxContainer, outgoing: VBoxContainer) -> void:
	_feed_container = feed
	_feed_scroll = feed_scroll
	_players_list = players
	_subscriptions_list = subscriptions
	_pending_requests_list = pending
	_outgoing_requests_list = outgoing

func add_feed_message(message: String, color: Color = Color.WHITE) -> void:
	var label := Label.new()
	label.text = message
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_feed_container.add_child(label)

func refresh_players_list(
	aliases: Array[TaloPlayerAlias],
	subscriptions_manager: FriendsListSubscriptionsManager,
	add_friend_callback: Callable
) -> void:
	_clear_container(_players_list)

	for alias in aliases:
		var container := HBoxContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# online indicator (green dot)
		var indicator := Label.new()
		indicator.text = "●"
		indicator.add_theme_color_override("font_color", Color.GREEN)
		indicator.tooltip_text = "Online"
		container.add_child(indicator)

		var name_label := Label.new()
		name_label.text = alias.identifier
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(name_label)

		var already_friends := subscriptions_manager.get_friends().find_custom(func (a): return a.id == alias.id) != -1
		var has_outgoing_request := subscriptions_manager.get_outgoing_requests().find_custom(func (a): return a.id == alias.id) != -1
		var has_pending_request := subscriptions_manager.get_pending_requests().find_custom(func (a): return a.id == alias.id) != -1

		var pending := has_outgoing_request or has_pending_request
		var disable_button = already_friends or pending

		var button := Button.new()
		button.text = "Pending" if pending else ("Friends" if already_friends else "Add Friend")
		button.disabled = disable_button
		if not already_friends and not has_outgoing_request:
			button.pressed.connect(func (): add_friend_callback.call(alias))
		container.add_child(button)

		_players_list.add_child(container)

func refresh_friends_list(friends: Array[TaloPlayerAlias], remove_friend_callback: Callable) -> void:
	_clear_container(_subscriptions_list)

	for friend in friends:
		var container := HBoxContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = friend.identifier
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(name_label)

		var button := Button.new()
		button.text = "Remove"
		button.pressed.connect(func (): remove_friend_callback.call(friend))
		container.add_child(button)

		_subscriptions_list.add_child(container)

func refresh_pending_requests_list(pending_requests: Array[TaloPlayerAlias], approve_callback: Callable) -> void:
	_clear_container(_pending_requests_list)

	for request in pending_requests:
		var container := HBoxContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = request.identifier
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(name_label)

		var approve_button := Button.new()
		approve_button.text = "Accept"
		approve_button.pressed.connect(func (): approve_callback.call(request))
		container.add_child(approve_button)

		_pending_requests_list.add_child(container)

func refresh_outgoing_requests_list(outgoing_requests: Array[TaloPlayerAlias], cancel_callback: Callable) -> void:
	_clear_container(_outgoing_requests_list)

	for request in outgoing_requests:
		var container := HBoxContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label := Label.new()
		name_label.text = request.identifier
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_child(name_label)

		var cancel_button := Button.new()
		cancel_button.text = "Cancel"
		cancel_button.pressed.connect(func (): cancel_callback.call(request))
		container.add_child(cancel_button)

		_outgoing_requests_list.add_child(container)

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()
