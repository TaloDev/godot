extends GdUnitTestSuite

func test_serialise_props_converts_each_prop_to_dictionary() -> void:
	var props: Array[TaloProp] = [TaloProp.new("color", "red"), TaloProp.new("size", "large")]

	var result := TaloPropUtils.serialise_props(props)

	assert_array(result).contains_exactly([
		{ key = "color", value = "red" },
		{ key = "size", value = "large" }
	])

func test_serialise_props_with_null_value_keeps_null() -> void:
	var props: Array[TaloProp] = [TaloProp.new("color", null)]

	var result := TaloPropUtils.serialise_props(props)

	assert_array(result).contains_exactly([{ key = "color", value = null }])

func test_serialise_props_with_array_key_preserves_individual_entries() -> void:
	var props: Array[TaloProp] = [TaloProp.new("items[]", "sword"), TaloProp.new("items[]", "shield")]

	var result := TaloPropUtils.serialise_props(props)

	assert_array(result).contains_exactly([
		{ key = "items[]", value = "sword" },
		{ key = "items[]", value = "shield" }
	])

func test_serialise_props_with_empty_array_returns_empty_array() -> void:
	var props: Array[TaloProp] = []

	var result := TaloPropUtils.serialise_props(props)

	assert_array(result).is_empty()
