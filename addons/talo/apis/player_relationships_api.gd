class_name PlayerRelationshipsAPI extends TaloAPI
## A unified API for managing player relationships (friends or followers).
##
## This API supports two relationship types:
## - BIDIRECTIONAL: Mutual relationships (both players must be connected)
## - UNIDIRECTIONAL: One-way relationships (follower/following pattern)
##
## @tutorial: https://docs.trytalo.com/docs/godot/relationships

## Emitted when another player sends the current player a relationship request.
signal relationship_request_received(player_alias: TaloPlayerAlias)

## Emitted when a relationship request is cancelled (from either side).
signal relationship_request_cancelled(player_alias: TaloPlayerAlias)

## Emitted when a relationship is confirmed (from either side).
signal relationship_confirmed(player_alias: TaloPlayerAlias)

## Emitted when a relationship ends (from either side).
signal relationship_ended(player_alias: TaloPlayerAlias)

## Emitted when a broadcast message is received from a connected player.
signal message_received(player_alias: TaloPlayerAlias, message: String)

func _init() -> void:
	super("/v1/players/relationships")
	name = "TaloPlayerRelationships"

func _ready() -> void:
	await Talo.init_completed
	Talo.socket.message_received.connect(_on_message_received)

func _on_message_received(res: String, data: Dictionary) -> void:
	match res:
		"v1.player-relationships.broadcast":
			message_received.emit(TaloPlayerAlias.new(data.playerAlias), data.message)
		"v1.player-relationships.subscription-created":
			var subscription := TaloPlayerAliasSubscription.new(data.subscription)
			relationship_request_received.emit(subscription.subscriber)
		"v1.player-relationships.subscription-confirmed":
			var subscription := TaloPlayerAliasSubscription.new(data.subscription)
			# emit who the other alias is
			var other_alias := subscription.subscriber if subscription.subscriber.player.id != Talo.current_player.id else subscription.subscribed_to
			relationship_confirmed.emit(other_alias)
		"v1.player-relationships.subscription-deleted":
			var subscription := TaloPlayerAliasSubscription.new(data.subscription)
			var other_alias := subscription.subscriber if subscription.subscriber.player.id != Talo.current_player.id else subscription.subscribed_to
			if subscription.confirmed:
				# confirmed subscription deleted = relationship ended
				relationship_ended.emit(other_alias)
			else:
				# unconfirmed subscription deleted = request cancelled
				relationship_request_cancelled.emit(other_alias)

## Broadcast a message to all confirmed subscribers via WebSocket.
func broadcast(message: String) -> void:
	if Talo.identity_check() != OK:
		return

	Talo.socket.send("v1.player-relationships.broadcast", {
		message = message
	})

## Subscribe to a player with a specific relationship type.
func subscribe_to(player_alias_id: int, relationship_type: TaloPlayerAliasSubscription.RelationshipType) -> TaloPlayerAliasSubscription:
	if Talo.identity_check() != OK:
		return null

	var type_string := _get_relationship_type_from_enum(relationship_type)
	var res := await client.make_request(HTTPClient.METHOD_POST, "", {
		aliasId = player_alias_id,
		relationshipType = type_string
	})

	match res.status:
		200:
			return TaloPlayerAliasSubscription.new(res.body.subscription)
		_:
			if res.has("body") and res.body.has("message"):
				push_error("Failed subscribing to player alias %s: %s" % [player_alias_id, res.body.message])
			return null

## Revoke a subscription by ID. For bidirectional subscriptions, the reciprocal relationship is automatically deleted.
func revoke_subscription(subscription_id: int) -> void:
	if Talo.identity_check() != OK:
		return

	var res := await client.make_request(HTTPClient.METHOD_DELETE, "/%s" % subscription_id)

	match res.status:
		404:
			push_error("Subscription not found")

## Unsubscribe from a player by alias ID. For bidirectional subscriptions, the reciprocal relationship is automatically deleted.
func unsubscribe_from(player_alias_id: int) -> bool:
	if Talo.identity_check() != OK:
		return false

	var options := GetSubscriptionsOptions.new()
	options.alias_id = player_alias_id
	var page := await get_subscriptions(options)

	if not page or page.subscriptions.is_empty():
		return false

	await revoke_subscription(page.subscriptions[0].id)
	return true

## Confirm a subscription request by ID. For bidirectional subscriptions, the reciprocal relationship is automatically created and confirmed.
func confirm_subscription_by_id(subscription_id: int) -> TaloPlayerAliasSubscription:
	if Talo.identity_check() != OK:
		return null

	var res := await client.make_request(HTTPClient.METHOD_PUT, "/%s/confirm" % subscription_id)

	match res.status:
		200:
			return TaloPlayerAliasSubscription.new(res.body.subscription)
		404:
			push_error("Subscription request not found")
			return null
		_:
			return null

## Confirm a subscription request by player alias ID. For bidirectional subscriptions, the reciprocal relationship is automatically created and confirmed.
func confirm_subscription_from(player_alias_id: int) -> bool:
	if Talo.identity_check() != OK:
		return false

	var options := GetSubscribersOptions.new()
	options.confirmed = ConfirmedFilter.UNCONFIRMED
	options.alias_id = player_alias_id
	var page := await get_subscribers(options)

	if not page or page.subscriptions.is_empty():
		push_error("No pending request from alias ID %s" % player_alias_id)
		return false

	var subscription: TaloPlayerAliasSubscription = page.subscriptions[0]
	var confirmed := await confirm_subscription_by_id(subscription.id)
	return confirmed != null

## Check if the current player has a subscription to a player. Optionally check if the subscription is confirmed.
func is_subscribed_to(player_alias_id: int, confirmed: bool) -> bool:
	if Talo.identity_check() != OK:
		return false

	var options := GetSubscriptionsOptions.new()
	options.confirmed = ConfirmedFilter.CONFIRMED if confirmed else ConfirmedFilter.ANY
	options.alias_id = player_alias_id
	var page := await get_subscriptions(options)

	if not page or page.subscriptions.is_empty():
		return false

	return true

## Get subscribers (players subscribed to the current player).
func get_subscribers(options := GetSubscribersOptions.new()) -> SubscriptionsListPage:
	if Talo.identity_check() != OK:
		return null

	var url := "/subscribers?page=%s"
	var url_data := [options.page]

	if options.confirmed != ConfirmedFilter.ANY:
		url += "&confirmed=%s"
		url_data.append("true" if options.confirmed == ConfirmedFilter.CONFIRMED else "false")

	if options.alias_id != -1:
		url += "&aliasId=%s"
		url_data.append(options.alias_id)

	if options.relationship_type != RelationshipTypeFilter.ANY:
		url += "&relationshipType=%s"
		url_data.append(_get_relationship_type_from_filter(options.relationship_type))

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var subscriptions: Array[TaloPlayerAliasSubscription] = []
			subscriptions.assign(res.body.subscriptions.map(func (sub: Dictionary): return TaloPlayerAliasSubscription.new(sub)))
			return SubscriptionsListPage.new(subscriptions, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

## Get subscriptions (players that the current player is subscribed to).
func get_subscriptions(options := GetSubscriptionsOptions.new()) -> SubscriptionsListPage:
	if Talo.identity_check() != OK:
		return null

	var url := "/subscriptions?page=%s"
	var url_data := [options.page]

	if options.confirmed != ConfirmedFilter.ANY:
		url += "&confirmed=%s"
		url_data.append("true" if options.confirmed == ConfirmedFilter.CONFIRMED else "false")

	if options.alias_id != -1:
		url += "&aliasId=%s"
		url_data.append(options.alias_id)

	if options.relationship_type != RelationshipTypeFilter.ANY:
		url += "&relationshipType=%s"
		url_data.append(_get_relationship_type_from_filter(options.relationship_type))

	var res := await client.make_request(HTTPClient.METHOD_GET, url % url_data)

	match res.status:
		200:
			var subscriptions: Array[TaloPlayerAliasSubscription] = []
			subscriptions.assign(res.body.subscriptions.map(func (sub: Dictionary): return TaloPlayerAliasSubscription.new(sub)))
			return SubscriptionsListPage.new(subscriptions, res.body.count, res.body.itemsPerPage, res.body.isLastPage)
		_:
			return null

func _get_relationship_type_from_enum(relationship_type: TaloPlayerAliasSubscription.RelationshipType) -> String:
	return "bidirectional" if relationship_type == TaloPlayerAliasSubscription.RelationshipType.BIDIRECTIONAL else "unidirectional"

func _get_relationship_type_from_filter(relationship_type: RelationshipTypeFilter) -> String:
	match relationship_type:
		RelationshipTypeFilter.BIDIRECTIONAL:
			return "bidirectional"
		RelationshipTypeFilter.UNIDIRECTIONAL:
			return "unidirectional"
		_:
			return ""

enum ConfirmedFilter {
	ANY,
	CONFIRMED,
	UNCONFIRMED
}

enum RelationshipTypeFilter {
	ANY = -1,
	UNIDIRECTIONAL = TaloPlayerAliasSubscription.RelationshipType.UNIDIRECTIONAL,
	BIDIRECTIONAL = TaloPlayerAliasSubscription.RelationshipType.BIDIRECTIONAL
}

class SubscriptionsListPage:
	var subscriptions: Array[TaloPlayerAliasSubscription]
	var count: int
	var items_per_page: int
	var is_last_page: bool

	func _init(subscriptions: Array[TaloPlayerAliasSubscription], count: int, items_per_page: int, is_last_page: bool) -> void:
		self.subscriptions = subscriptions
		self.count = count
		self.items_per_page = items_per_page
		self.is_last_page = is_last_page

class GetSubscribersOptions:
	var page: int = 0
	var confirmed: ConfirmedFilter = ConfirmedFilter.ANY
	var alias_id: int = -1
	var relationship_type: RelationshipTypeFilter = RelationshipTypeFilter.ANY

class GetSubscriptionsOptions:
	var page: int = 0
	var confirmed: ConfirmedFilter = ConfirmedFilter.ANY
	var alias_id: int = -1
	var relationship_type: RelationshipTypeFilter = RelationshipTypeFilter.ANY
