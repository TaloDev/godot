class_name FriendsListSubscriptionsManager extends RefCounted

signal friends_updated()
signal pending_requests_updated()
signal outgoing_requests_updated()

var _friends: Array[TaloPlayerAlias] = []
var _pending_requests: Array[TaloPlayerAlias] = []
var _outgoing_requests: Array[TaloPlayerAlias] = []

func get_friends() -> Array[TaloPlayerAlias]:
	return _friends

func get_pending_requests() -> Array[TaloPlayerAlias]:
	return _pending_requests

func get_outgoing_requests() -> Array[TaloPlayerAlias]:
	return _outgoing_requests

func refresh_all_data() -> void:
	await load_friends()
	await load_outgoing_requests()
	await load_pending_requests()

# confirmed friends
func load_friends() -> void:
	var options := Talo.player_relationships.GetSubscriptionsOptions.new()
	options.confirmed = Talo.player_relationships.ConfirmedFilter.CONFIRMED
	var page := await Talo.player_relationships.get_subscriptions(options)
	_friends.assign(page.subscriptions.map(func (sub: TaloPlayerAliasSubscription): return sub.subscribed_to))
	friends_updated.emit()

# unconfirmed requests other players have sent to the current player
func load_pending_requests() -> void:
	var options := Talo.player_relationships.GetSubscribersOptions.new()
	options.confirmed = Talo.player_relationships.ConfirmedFilter.UNCONFIRMED
	var page := await Talo.player_relationships.get_subscribers(options)
	_pending_requests.assign(page.subscriptions.map(func (sub: TaloPlayerAliasSubscription): return sub.subscriber))
	pending_requests_updated.emit()

# unconfirmed requests the current player has sent
func load_outgoing_requests() -> void:
	var options := Talo.player_relationships.GetSubscriptionsOptions.new()
	options.confirmed = Talo.player_relationships.ConfirmedFilter.UNCONFIRMED
	var page := await Talo.player_relationships.get_subscriptions(options)
	_outgoing_requests.assign(page.subscriptions.map(func (sub: TaloPlayerAliasSubscription): return sub.subscribed_to))
	outgoing_requests_updated.emit()

func send_friend_request(alias: TaloPlayerAlias) -> bool:
	var subscription := await Talo.player_relationships.subscribe_to(alias.id, TaloPlayerAliasSubscription.RelationshipType.BIDIRECTIONAL)
	return subscription != null

func accept_friend_request(alias: TaloPlayerAlias) -> bool:
	return await Talo.player_relationships.confirm_subscription_from(alias.id)

func remove_friend(alias: TaloPlayerAlias) -> bool:
	return await Talo.player_relationships.unsubscribe_from(alias.id)
