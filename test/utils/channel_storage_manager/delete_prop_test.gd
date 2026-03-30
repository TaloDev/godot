extends GdUnitTestSuite

func test_delete_prop_removes_prop() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	manager.delete_prop(1, "color")

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("")

func test_delete_prop_leaves_other_props_intact() -> void:
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

	manager.delete_prop(1, "color")

	assert_str(manager._get_entity(1).get_prop("size")).is_equal("large")

func test_delete_prop_removes_all_entries_for_array_key() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["sword","shield"]'
		}
	}))

	manager.delete_prop(1, "items[]")

	assert_array(manager._get_entity(1).get_prop_array("items")).is_empty()

func test_delete_prop_leaves_other_array_props_intact() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["sword","shield"]'
		}
	}), true)

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "tags[]",
			"value": '["rpg","fantasy"]'
		}
	}), true)

	manager.delete_prop(1, "items[]")

	assert_array(manager._get_entity(1).get_prop_array("tags")).contains_exactly(["rpg", "fantasy"])

func test_delete_prop_is_isolated_per_channel() -> void:
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

	manager.delete_prop(1, "color")

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("")
	assert_str(manager._get_entity(2).get_prop("color")).is_equal("blue")
