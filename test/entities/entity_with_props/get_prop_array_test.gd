extends GdUnitTestSuite

func test_get_prop_array_with_existing_items_returns_all_values() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
		TaloProp.new("items[]", "potion"),
	])

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield", "potion"])

func test_get_prop_array_with_no_matching_key_returns_empty_array() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
	])

	assert_array(player.get_prop_array("other")).is_empty()

func test_get_prop_array_accepts_key_with_or_without_brackets() -> void:
	var player := TaloEntityWithProps.new([
		TaloProp.new("items[]", "sword"),
		TaloProp.new("items[]", "shield"),
	])

	assert_array(player.get_prop_array("items")).contains_exactly(["sword", "shield"])
	assert_array(player.get_prop_array("items[]")).contains_exactly(["sword", "shield"])
