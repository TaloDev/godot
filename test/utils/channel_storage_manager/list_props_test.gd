extends GdUnitTestSuite

func test_list_props_returns_cached_scalar_props() -> void:
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

	var result := await manager.list_props(1, ["color", "size"])
	assert_int(result.size()).is_equal(2)

func test_list_props_returns_all_cached_prop_array_entries() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "items[]",
			"value": '["sword","shield","potion"]'
		}
	}), true)

	var result := await manager.list_props(1, ["items[]"])
	assert_int(result.size()).is_equal(3)
	var values := result.map(func (p: TaloChannelStorageProp) -> String: return p.value)
	assert_array(values).contains_exactly(["sword", "shield", "potion"])
