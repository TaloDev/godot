class_name TaloFixtures extends RefCounted

static func _get_fixture_params(params: Dictionary[String, Variant], key: String) -> Dictionary:
	if !params.has(key):
		return {}
	return params[key]

static func player_factory(params: Dictionary[String, Variant] = {}) -> Dictionary:
	var data := _get_fixture_params(params, "player")
	return {
		id = data.get("id", "player-1"),
		props = [],
		groups = [],
		aliases = []
	}

static func make_player(params: Dictionary[String, Variant] = {}) -> TaloPlayer:
	return TaloPlayer.new(player_factory(params))

static func player_alias_factory(params: Dictionary[String, Variant] = {}) -> Dictionary:
	var data := _get_fixture_params(params, "player_alias")
	return {
		id = data.get("id", 1),
		service = data.get("service", "test"),
		identifier = data.get("identifier", "test_player"),
		player = player_factory(params),
		lastSeenAt = "",
		createdAt = "",
		updatedAt = ""
	}

static func make_alias(params: Dictionary[String, Variant] = {}) -> TaloPlayerAlias:
	return TaloPlayerAlias.new(player_alias_factory(params))

static func channel_factory(params: Dictionary[String, Variant] = {}) -> Dictionary:
	var data := _get_fixture_params(params, "channel")
	return {
		id = data.get("id", 1),
		name = data.get("name", "Test Channel"),
		owner = player_alias_factory(params),
		props = [],
		totalMessages = 0,
		memberCount = 0,
		private = false,
		createdAt = "",
		updatedAt = ""
	}

static func make_channel(params: Dictionary[String, Variant] = {}) -> TaloChannel:
	return TaloChannel.new(channel_factory(params))

static func channel_storage_prop_factory(params: Dictionary[String, Variant] = {}) -> Dictionary:
	var data := _get_fixture_params(params, "channel_storage_prop")
	var alias := player_alias_factory(params)
	return {
		key = data.get("key", "test_key"),
		value = data.get("value", "test_value"),
		createdBy = alias,
		lastUpdatedBy = alias,
		createdAt = "",
		updatedAt = ""
	}

static func make_channel_storage_prop(params: Dictionary[String, Variant] = {}) -> TaloChannelStorageProp:
	return TaloChannelStorageProp.new(channel_storage_prop_factory(params))
