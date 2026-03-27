extends GdUnitTestSuite

func test_get_prop_with_an_existing_key_returns_correct_value() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	assert_str(player.get_prop("key2")).is_equal("value2")

func test_get_prop_with_a_missing_key_returns_empty_string() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	assert_str(player.get_prop("key3")).is_equal("")

func test_get_prop_with_a_missing_key_and_fallback_returns_fallback() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("key1", "value1"),
		TaloProp.new("key2", "value2"),
	])

	assert_str(player.get_prop("key3", "value3")).is_equal("value3")
