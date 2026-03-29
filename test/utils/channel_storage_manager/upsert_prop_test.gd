extends GdUnitTestSuite

func test_upsert_prop_adds_new_prop() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")

func test_upsert_prop_replaces_existing_prop() -> void:
	var manager := TaloChannelStorageManager.new()

	# initial prop
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	# updated prop
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "blue"
		}
	}))

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("blue")

func test_upsert_prop_preserves_other_props() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "size",
			"value": "large"
		}
	}))
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "blue"
		}
	}))

	assert_str(manager._get_entity(1).get_prop("size")).is_equal("large")

func test_upsert_prop_with_expand_and_array_key_expands_into_individual_props() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["sword","shield"]'
		}
	}), true)

	assert_array(manager._get_entity(1).get_prop_array("items")).contains_exactly(["sword", "shield"])

func test_upsert_prop_with_expand_replaces_all_previous_array_entries() -> void:
	var manager := TaloChannelStorageManager.new()

	# initial prop array
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["sword","shield"]'
		}
	}), true)

	# updated prop array
	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["potion"]'
		}
	}), true)

	assert_array(manager._get_entity(1).get_prop_array("items")).contains_exactly(["potion"])

func test_upsert_prop_is_isolated_per_channel() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))
	manager.upsert_prop(2, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "blue"
		}
	}))

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")
	assert_str(manager._get_entity(2).get_prop("color")).is_equal("blue")
