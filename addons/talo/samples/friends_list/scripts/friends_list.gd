class_name FriendsListSample extends Node2D

const RANDOM_NAMES := ["Alice", "Bob", "Carl", "Doric", "Eve", "Fred", "Gina", "Hank"]

const PlayersManager := preload("res://addons/talo/samples/friends_list/scripts/players_manager.gd")
const SubscriptionsManager := preload("res://addons/talo/samples/friends_list/scripts/subscriptions_manager.gd")
const UIManager := preload("res://addons/talo/samples/friends_list/scripts/ui_manager.gd")

var _player_name: String
var _players_manager: PlayersManager
var _subscriptions_manager: SubscriptionsManager
var _ui_manager: UIManager

static var lookingForFriendsStatus := "Looking for friends!"

func _ready() -> void:
	_initialize_managers()
	_connect_signals()
	_identify_player()

func _identify_player() -> void:
	_player_name = _generate_random_name()
	await Talo.players.identify("username", _player_name)

	# update the UI to reflect the identified player
	_ui_manager.add_feed_message("Identified as %s" % _player_name, Color.CYAN)
	%YourNameLabel.text = "You are: %s" % _player_name
	_send_intro_feed_messages()

	# create a presence update after a short delay
	# this notifies other clients that we are online
	await get_tree().create_timer(2.0).timeout
	await Talo.player_presence.update_presence(true, lookingForFriendsStatus)

func _initialize_managers() -> void:
	_players_manager = FriendsListPlayersManager.new()
	_subscriptions_manager = FriendsListSubscriptionsManager.new()
	_ui_manager = FriendsListUIManager.new(
		%Feed,
		%FeedScroll,
		%PlayersList,
		%SubscriptionsList,
		%PendingRequestsList,
		%OutgoingRequestsList
	)

	_players_manager.players_updated.connect(_on_players_updated)
	_subscriptions_manager.friends_updated.connect(_on_friends_updated)
	_subscriptions_manager.pending_requests_updated.connect(_on_pending_requests_updated)
	_subscriptions_manager.outgoing_requests_updated.connect(_on_outgoing_requests_updated)

func _connect_signals() -> void:
	Talo.player_presence.presence_changed.connect(_on_presence_changed)
	Talo.player_relationships.message_received.connect(_on_message_received)
	Talo.player_relationships.relationship_request_received.connect(_on_relationship_request_received)
	Talo.player_relationships.relationship_request_cancelled.connect(_on_relationship_request_cancelled)
	Talo.player_relationships.relationship_confirmed.connect(_on_relationship_confirmed)
	Talo.player_relationships.relationship_ended.connect(_on_relationship_ended)

func _send_intro_feed_messages() -> void:
	_ui_manager.add_feed_message("Run this scene with multiple instances to test it.", Color.GRAY)
	_ui_manager.add_feed_message("Go to Debug > Customize Run Instances and tick 'Enable Multiple Instances'.", Color.GRAY)

func _generate_random_name() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var base_name: String = RANDOM_NAMES[rng.randi_range(0, RANDOM_NAMES.size() - 1)]
	var suffix := rng.randi_range(1, 999)
	return "%s%d" % [base_name, suffix]

func _refresh_all_data() -> void:
	_on_players_updated()
	await _subscriptions_manager.refresh_all_data()

func _on_players_updated() -> void:
	var online_players := _players_manager.get_online_aliases()
	# ensure the "Add Friend" button is in the correct state
	_ui_manager.refresh_players_list(online_players, _subscriptions_manager, _on_add_friend)

func _on_friends_updated() -> void:
	_ui_manager.refresh_friends_list(_subscriptions_manager.get_friends(), _on_remove_friend)
	_on_players_updated()

func _on_pending_requests_updated() -> void:
	_ui_manager.refresh_pending_requests_list(_subscriptions_manager.get_pending_requests(), _on_approve_request)
	_on_players_updated()

func _on_outgoing_requests_updated() -> void:
	_ui_manager.refresh_outgoing_requests_list(_subscriptions_manager.get_outgoing_requests(), _on_cancel_request)
	_on_players_updated()

func _on_message_received(player_alias: TaloPlayerAlias, message: String) -> void:
	_ui_manager.add_feed_message("[%s]: %s" % [player_alias.identifier, message], Color.LIGHT_BLUE)

func _on_presence_changed(presence: TaloPlayerPresence, _online_changed: bool, _custom_status_changed: bool) -> void:
	# only mark players as online if they have the custom status
	if presence.online and presence.custom_status != lookingForFriendsStatus:
		return

	var status_text: String = "looking for friends" if presence.online else "offline"
	var status_color := Color.GREEN if presence.online else Color.GRAY
	var identifier := "You are" if presence.player_alias.id == Talo.current_alias.id else (presence.player_alias.identifier + " is")
	_ui_manager.add_feed_message("%s now %s" % [identifier, status_text], status_color)
	_players_manager.handle_presence_changed(presence)

func _on_relationship_request_received(player_alias: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("%s sent you a friend request!" % player_alias.identifier, Color.YELLOW)
	await _subscriptions_manager.load_pending_requests()

func _on_relationship_request_cancelled(player_alias: TaloPlayerAlias) -> void:
	# reload both incoming and outgoing requests
	# (incoming if they cancelled their request to the player, outgoing if the player cancelled theirs)
	await _subscriptions_manager.load_pending_requests()
	await _subscriptions_manager.load_outgoing_requests()

func _on_relationship_confirmed(player_alias: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("%s accepted your friend request!" % player_alias.identifier, Color.GREEN)
	await _subscriptions_manager.load_friends()
	await _subscriptions_manager.load_outgoing_requests()

func _on_relationship_ended(player_alias: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("You are no longer friends with %s" % player_alias.identifier, Color.GRAY)
	await _subscriptions_manager.load_friends()
	await _subscriptions_manager.load_pending_requests()

func _on_send_broadcast_pressed() -> void:
	var message: String = %BroadcastInput.text.strip_edges()
	if message.is_empty():
		return

	Talo.player_relationships.broadcast(message)
	_ui_manager.add_feed_message("[You]: %s" % message, Color.LIGHT_GREEN)
	%BroadcastInput.text = ""

func _on_broadcast_input_text_submitted(_new_text: String) -> void:
	_on_send_broadcast_pressed()

func _on_add_friend(alias: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("Sending friend request to %s..." % alias.identifier, Color.CYAN)
	var success := await _subscriptions_manager.send_friend_request(alias)

	if success:
		_ui_manager.add_feed_message("Friend request sent to %s" % alias.identifier, Color.YELLOW)
		await _refresh_all_data()
	else:
		_ui_manager.add_feed_message("Failed to send request to %s" % alias.identifier, Color.RED)

func _on_remove_friend(friend: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("Removing %s..." % friend.identifier, Color.CYAN)
	var success := await _subscriptions_manager.remove_friend(friend)
	if success:
		_ui_manager.add_feed_message("Removed %s from friends" % friend.identifier, Color.GREEN)
		await _refresh_all_data()
	else:
		_ui_manager.add_feed_message("Failed to remove %s" % friend.identifier, Color.RED)

func _on_approve_request(requester: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("Accepting friend request from %s..." % requester.identifier, Color.CYAN)
	var success := await _subscriptions_manager.accept_friend_request(requester)

	if success:
		_ui_manager.add_feed_message("Accepted! %s is now your friend" % requester.identifier, Color.GREEN)
		await _refresh_all_data()
	else:
		_ui_manager.add_feed_message("Failed to accept friend request", Color.RED)

func _on_cancel_request(player: TaloPlayerAlias) -> void:
	_ui_manager.add_feed_message("Cancelling friend request to %s..." % player.identifier, Color.CYAN)
	var success := await _subscriptions_manager.remove_friend(player)
	if success:
		_ui_manager.add_feed_message("Cancelled friend request to %s" % player.identifier, Color.GRAY)
		await _refresh_all_data()
	else:
		_ui_manager.add_feed_message("Failed to cancel request to %s" % player.identifier, Color.RED)
