extends GdUnitTestSuite

func test_set_prop_when_prop_does_not_already_exist_appends_the_new_prop() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	player.set_prop("key3", "value3")

	assert_str(player.get_prop("key3")).is_equal("value3")

func test_set_prop_when_prop_already_exists_updates_the_prop() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	player.set_prop("key2", "2value2updated")

	assert_str(player.get_prop("key2")).is_equal("2value2updated")
