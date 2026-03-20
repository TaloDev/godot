extends GdUnitTestSuite

func test_delete_prop_when_the_prop_exists_sets_the_value_to_null() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	player.delete_prop("key2")
	assert_object(player.props[1].value).is_null()

func test_delete_prop_when_the_prop_does_not_exist_does_nothing() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	player.delete_prop("key3")
	assert_int(player.props.size()).is_equal(2)
