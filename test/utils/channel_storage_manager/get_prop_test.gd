extends GdUnitTestSuite

func test_get_prop_returns_cached_prop() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		},
		"player_alias": {
			"id": 123
		}
	}))

	var result := await manager.get_prop(1, "color")
	assert_str(result.value).is_equal("red")
	assert_int(result.created_by_alias.id).is_equal(123)

func test_get_prop_returns_null_when_prop_is_deleted() -> void:
	var manager := TaloChannelStorageManager.new()

	manager.upsert_prop(1, TaloFixtures.make_channel_storage_prop({
		"channel_storage_prop": {
			"key": "color",
			"value": "red"
		}
	}))

	manager.delete_prop(1, "color")

	var entity := manager._get_entity(1)
	var cached := entity.props.filter(func (p: TaloProp) -> bool: return p.key == "color" && p.value != null)
	assert_array(cached).is_empty()
