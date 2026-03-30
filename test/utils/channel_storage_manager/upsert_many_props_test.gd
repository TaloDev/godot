extends GdUnitTestSuite

func test_upsert_many_props_adds_all_props() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_many_props(1, [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "red"
			}
		}),
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "size",
				"value": "large"
			}
		})
	])

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")
	assert_str(manager._get_entity(1).get_prop("size")).is_equal("large")

func test_upsert_many_props_replaces_existing_props() -> void:
	var manager := TaloChannelStorageManager.new()

	# initial props
	manager.upsert_many_props(1, [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "red"
			}
		}),
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "size",
				"value": "large"
			}
		})
	])

	# updated props
	manager.upsert_many_props(1, [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "blue"
			}
		}),
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "size",
				"value": "small"
			}
		})
	])

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("blue")
	assert_str(manager._get_entity(1).get_prop("size")).is_equal("small")

func test_upsert_many_props_stores_array_props_as_individual_entries() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_many_props(1, [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "items[]",
				"value": "sword"
			}
		}),
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "items[]",
				"value": "shield"
			}
		}),
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "red"
			}
		})
	])

	assert_array(manager._get_entity(1).get_prop_array("items")).contains_exactly(["sword", "shield"])
	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")

func test_upsert_many_props_with_empty_array_does_nothing() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	manager.upsert_many_props(1, [])

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")
