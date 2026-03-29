extends GdUnitTestSuite

func test_on_props_updated_upserts_new_props() -> void:
	var manager := TaloChannelStorageManager.new()

	var channel := TaloFixtures.make_channel()

	var upserted: Array[TaloChannelStorageProp] = [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "red"
			}
		})
	]

	var deleted: Array[TaloChannelStorageProp] = []

	manager.on_props_updated(channel, upserted, deleted)

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("red")

func test_on_props_updated_deletes_props() -> void:
	var manager := TaloChannelStorageManager.new()

	var channel := TaloFixtures.make_channel()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	var upserted: Array[TaloChannelStorageProp] = []

	var deleted: Array[TaloChannelStorageProp] = [TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	})]

	manager.on_props_updated(channel, upserted, deleted)

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("")

func test_on_props_updated_handles_upserts_and_deletes_together() -> void:
	var manager := TaloChannelStorageManager.new()

	var channel := TaloFixtures.make_channel()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	var upserted: Array[TaloChannelStorageProp] = [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "size",
				"value": "large"
			}
		})
	]

	var deleted: Array[TaloChannelStorageProp] = [
		TaloFixtures.make_channel_storage_prop({
			"channel_storage_prop": {
				"key": "color",
				"value": "red"
			}
		})
	]

	manager.on_props_updated(channel, upserted, deleted)

	assert_str(manager._get_entity(1).get_prop("color")).is_equal("")
	assert_str(manager._get_entity(1).get_prop("size")).is_equal("large")
